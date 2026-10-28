En esta primera fase construiremos nuestro **Productor de Eventos (`producer.py`)**. 

Para simular un entorno real donde los sensores móviles o microservicios pierden conexión y reenvían sus paquetes minutos después, nuestro productor generará tráfico continuo cada medio segundo con tres comportamientos:
* **Eventos Normales:** `Event Time == Processing Time`.
* **Llegada Tardía Moderada (Cada 15 eventos):** Inyecta un error `HTTP 500` en `/api/pagos` con un `event_time` atrasado **8 segundos** respecto al reloj actual.
* **Llegada Muy Tardía / Obsoleta (Cada 25 eventos):** Inyecta un error `HTTP 500` en `/api/login` con un `event_time` atrasado **35 segundos**.

### 1. Crear el script generador
Haz clic en el siguiente bloque para crear el archivo `/root/lab-streaming/producer.py` en la **Terminal 1**:

```bash
cat << 'EOF' > /root/lab-streaming/producer.py
import time, random, os
from datetime import datetime, timedelta

LOG_FILE = "/tmp/stream_logs.csv"
STREAM_DIR = "/tmp/stream_dir"
os.makedirs(STREAM_DIR, exist_ok=True)

rutas = ["/api/pagos", "/api/login", "/api/carrito", "/api/catalogo"]
codigos = [200, 200, 200, 404, 500]

print("🚀 Iniciando Generador de Stream...")
print("   -> Archivo continuo: /tmp/stream_logs.csv")
print("   -> Micro-lotes Spark: /tmp/stream_dir/\n")

with open(LOG_FILE, "w") as f:
    f.write("ip,event_time,ruta,status,latencia_ms\n")

iteracion = 0
lote_buffer = []

while True:
    iteracion += 1
    ahora = datetime.now()
    ip = f"192.168.1.{random.randint(10, 99)}"
    ruta = random.choice(rutas)
    status = random.choice(codigos)
    latencia = random.randint(15, 450)

    # 1. Simulación de Hecho Tardío (-8 segundos: Dentro del Watermark de 15s)
    if iteracion % 15 == 0:
        t_evento = (ahora - timedelta(seconds=8)).strftime("%Y-%m-%d %H:%M:%S")
        linea = f"{ip},{t_evento},/api/pagos,500,999\n"
        print(f"⚠️  [LATE EVENT -8s]       -> {linea.strip()}")
    
    # 2. Simulación de Hecho Muy Tardío (-35 segundos: Fuera del Watermark de 15s)
    elif iteracion % 25 == 0:
        t_evento = (ahora - timedelta(seconds=35)).strftime("%Y-%m-%d %H:%M:%S")
        linea = f"{ip},{t_evento},/api/login,500,888\n"
        print(f"❌ [VERY LATE EVENT -35s] -> {linea.strip()}")
    
    # 3. Evento Normal en tiempo real
    else:
        t_evento = ahora.strftime("%Y-%m-%d %H:%M:%S")
        linea = f"{ip},{t_evento},{ruta},{status},{latencia}\n"
        print(f"✅ [NORMAL]               -> {linea.strip()}")

    # Escribir en el log continuo (para Fase 2: Unix Pipes / Hadoop Streaming)
    with open(LOG_FILE, "a") as f:
        f.write(linea)
        f.flush()

    # Escribir micro-archivo cada 4 eventos (para Fase 3: PySpark Structured Streaming)
    lote_buffer.append(linea)
    if len(lote_buffer) >= 4:
        batch_file = os.path.join(STREAM_DIR, f"batch_{iteracion}.csv")
        with open(batch_file, "w") as bf:
            bf.write("ip,event_time,ruta,status,latencia_ms\n")
            bf.writelines(lote_buffer)
        lote_buffer = []

    time.sleep(0.5)
EOF
```{{execute T1}}

### 2. Iniciar el flujo de datos en vivo
Ejecuta el productor en la **Terminal 1** y déjalo corriendo durante todo el laboratorio:

```bash
python3 /root/lab-streaming/producer.py
```{{execute T1}}

Observa cómo empiezan a generarse las líneas de log y presta atención cuando aparezcan las alertas `⚠️ [LATE EVENT -8s]` y `❌ [VERY LATE EVENT -35s]`. ¡No detengas esta terminal! Avanza al siguiente paso.