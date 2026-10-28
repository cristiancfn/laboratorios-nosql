Para resolver el problema de agotamiento de memoria RAM sin perder la capacidad de procesar rezagados legítimos, utilizaremos **PySpark Structured Streaming** con **Watermarking** en la **Terminal 2**.

Configuraremos:
* **Tumbling Window:** `10 seconds` basada en la columna `event_time`.
* **Watermark:** `15 seconds`.
  * *Fórmula del Motor:* `Watermark = max(Event Time visto) - 15 segundos`

Esto significa que:
1. El evento tardío de **`-8s`** (`Event Time >= Watermark`) encontrará su ventana aún viva en RAM y **actualizará el conteo correctamente**.
2. El evento muy tardío de **`-35s`** (`Event Time < Watermark`) caerá en una ventana ya recolectada por el *Garbage Collector* y **será descartado automáticamente** para proteger la RAM del clúster.

### 1. Crear el consumidor Stateful (`spark_consumer.py`)
Haz clic en el bloque para generar el script de PySpark en la **Terminal 2**:

```bash
cat << 'EOF' > /root/lab-streaming/spark_consumer.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, window

spark = SparkSession.builder \
    .appName("StreamingMedallonWatermark") \
    .master("local[2]") \
    .config("spark.sql.shuffle.partitions", "2") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

esquema = "ip STRING, event_time TIMESTAMP, ruta STRING, status INT, latencia_ms INT"

# 1. Lectura del flujo desde el directorio de aterrizaje (Capa Bronce)
df_bronce = spark.readStream \
    .schema(esquema) \
    .option("header", "true") \
    .csv("/tmp/stream_dir")

# 2. Filtrado + Watermark (15s) + Tumbling Window (10s) (Capa Plata -> Oro)
df_oro = df_bronce \
    .filter(col("status").isin(404, 500)) \
    .withWatermark("event_time", "15 seconds") \
    .groupBy(
        window(col("event_time"), "10 seconds"),
        col("ruta"),
        col("status")
    ).count()

# 3. Escritura en consola en modo UPDATE (emite solo las ventanas que cambiaron en el micro-batch)
consulta = df_oro.writeStream \
    .outputMode("update") \
    .format("console") \
    .option("truncate", "false") \
    .trigger(processingTime="5 seconds") \
    .start()

print("⚡ Motor PySpark Structured Streaming iniciado. Esperando micro-lotes cada 5s...")
consulta.awaitTermination()
EOF
```{{execute T2}}

### 2. Ejecutar el motor de Streaming con Watermarking
Lanza el consumidor de PySpark en la **Terminal 2**:

```bash
python3 /root/lab-streaming/spark_consumer.py
```{{execute T2}}

### 🔍 Verificación del Experimento:
Observa las tablas `Batch: X` que PySpark imprime cada 5 segundos en la **Terminal 2** mientras comparas con la **Terminal 1**:
1. Cuando en la Terminal 1 se inyecta un `⚠️ [LATE EVENT -8s]` hacia `/api/pagos` (código `500`), verás que en el siguiente `Batch` de PySpark **aparece actualizada una ventana de 10 segundos anterior**, incrementando su columna `count`.
2. Cuando en la Terminal 1 se inyecta un `❌ [VERY LATE EVENT -35s]` hacia `/api/login` (código `500`), verás que PySpark **no reabre ni emite esa ventana antigua**, pues su marca de agua ya superó los 15 segundos de tolerancia y el estado obsoleto fue purgado de la memoria RAM.