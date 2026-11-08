# Paso 5: Ejecución en YARN y Exportación hacia el Modelo Dimensional

Una vez validada la lógica de nuestro `mapper.py` y `reducer.py`, es momento de lanzar el procesamiento distribuido real sobre el clúster utilizando **YARN** y la librería oficial **Hadoop Streaming**.

---

### 5.1 Ejecutar el Trabajo MapReduce en el Clúster

El comando `hadoop jar` invocará el paquete `hadoop-streaming-3.3.6.jar` pasando cuatro parámetros esenciales:
* `-files`: Empaqueta y distribuye nuestros scripts de Python a los nodos trabajadores.
* `-mapper` y `-reducer`: Define los ejecutables de cada fase.
* `-input`: Ruta de origen en HDFS (`/datalake/raw/pos_logs/raw_pos_transactions.log`).
* `-output`: Directorio de destino en HDFS (`/datalake/refined/fact_ventas_diarias`). **Importante:** En Hadoop, el directorio de salida no debe existir previamente (para evitar sobrescrituras accidentales).

Además, usaremos `-D mapreduce.output.textoutputformat.separator=""` para que el archivo final quede en formato CSV limpio sin tabuladores residuales al final de cada línea.

Ejecuta el trabajo en el clúster (tomará alrededor de 20 a 35 segundos):

```bash
hadoop jar /opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar \
  -D mapreduce.output.textoutputformat.separator="" \
  -files /root/mapreduce/mapper.py,/root/mapreduce/reducer.py \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input /datalake/raw/pos_logs/raw_pos_transactions.log \
  -output /datalake/refined/fact_ventas_diarias
```{{exec}}

Observa en la consola el progreso de tipo `map 0% reduce 0%` hasta llegar a `map 100% reduce 100%` y las estadísticas finales (*Map-Reduce Framework*: registros de entrada, registros de salida y bytes procesados).

> **Inspecciona el Orquestador YARN:** Puedes abrir la interfaz gráfica del **ResourceManager** para ver el historial y estado de la aplicación ejecutada haciendo clic aquí:
> [Abrir Interfaz Web de YARN ResourceManager (Puerto 8088)]({{TRAFFIC_HOST1_8088}})

---

### 5.2 Inspeccionar el Resultado en HDFS

Lista el contenido de la carpeta de salida que MapReduce acaba de crear en `/datalake/refined/fact_ventas_diarias`:

```bash
hdfs dfs -ls -h /datalake/refined/fact_ventas_diarias
```{{exec}}

Verás dos elementos:
1. **`_SUCCESS`**: Un archivo vacío (bandera o *flag*) que certifica a otros sistemas de orquestación que la transacción MapReduce terminó sin errores.
2. **`part-00000`**: El archivo con los datos agregados emitidos por el Reducer (si hubiéramos configurado múltiples Reducers, veríamos `part-00000`, `part-00001`, etc.).

Visualiza las primeras 15 líneas del archivo resultante directamente desde HDFS:

```bash
hdfs dfs -cat /datalake/refined/fact_ventas_diarias/part-00000 | head -n 15
```{{exec}}

---

### 5.3 Consolidar y Exportar el CSV para la Bodega de Datos

En una arquitectura real, un proceso de ingesta hacia el Data Warehouse toma todos los fragmentos `part-*` de HDFS y los consolida.

Crearemos una carpeta `/root/export_dw`, pondremos la fila de encabezados de nuestra **Tabla de Hechos** y utilizaremos el comando `hdfs dfs -getmerge` para unir la salida de HDFS y anexarla a nuestro archivo final `fact_ventas_diarias.csv`:

```bash
mkdir -p /root/export_dw

# 1. Crear el encabezado del CSV con los nombres de columnas del Modelo Dimensional
echo "id_fecha,id_tienda,id_producto,metodo_pago,cantidad_transacciones,unidades_vendidas,ingreso_bruto_total" > /root/export_dw/fact_ventas_diarias.csv

# 2. Extraer y fusionar los bloques de salida de HDFS en un archivo temporal y concatenarlo al CSV
hdfs dfs -getmerge /datalake/refined/fact_ventas_diarias/part-* /tmp/merged_output.csv
cat /tmp/merged_output.csv >> /root/export_dw/fact_ventas_diarias.csv
rm /tmp/merged_output.csv
```{{exec}}

Comprueba el resultado final comparando el volumen de datos antes y después del procesamiento:
* Pasamos de **50,000 líneas crudas y sucias** a cerca de **~3,600 registros diarios limpios y agregados**:

```bash
wc -l /root/export_dw/fact_ventas_diarias.csv && head -n 15 /root/export_dw/fact_ventas_diarias.csv
```{{exec}}

---

### 5.4 Descargar el Archivo para tu Modelo Dimensional

Si deseas descargar este archivo `fact_ventas_diarias.csv` a tu computador para cargarlo posteriormente en tu motor de Bodega de Datos o herramienta de visualización, levanta un servidor web ligero en el puerto `8080`:

```bash
nohup python3 -m http.server 8080 --directory /root/export_dw > /tmp/http.log 2>&1 &
echo "Servidor de descarga activo en el puerto 8080"
```{{exec}}

Haz clic en el siguiente enlace para abrir el directorio en tu navegador y descargar `fact_ventas_diarias.csv`:
👉 **[Descargar fact_ventas_diarias.csv desde el Servidor (Puerto 8080)]({{TRAFFIC_HOST1_8080}})**