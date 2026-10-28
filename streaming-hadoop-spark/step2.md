Mientras la **Terminal 1** sigue emitiendo tráfico en vivo, usaremos una **segunda terminal (Terminal 2)** para procesar los datos bajo el paradigma clásico de **Hadoop Streaming** (`stdin -> Mapper -> Reducer -> stdout`).

Queremos contar únicamente los errores **HTTP 404 y 500** agrupados en **Tumbling Windows de 10 segundos** basadas en el `event_time` del registro.

### 1. Crear el script `mapper.py`
Haz clic abajo para crear el Mapper en la **Terminal 2**. Este script filtra los códigos `404` y `500`, trunca el segundo del `event_time` a decenas (ej. `14:20:37` -> `14:20:30`) para asignarle su ventana de 10 segundos y emite el par `clave \t 1`:

```bash
cat << 'EOF' > /root/lab-streaming/mapper.py
import sys

for linea in sys.stdin:
    linea = linea.strip()
    if not linea or linea.startswith("ip,"):
        continue
    partes = linea.split(",")
    if len(partes) == 5:
        ip, event_time, ruta, status, latencia = partes
        if status in ["404", "500"]:
            # Truncamos el último dígito de los segundos para armar Tumbling Window de 10s
            ventana_10s = event_time[:-1] + "0"
            print(f"{ventana_10s}|{ruta}|{status}\t1", flush=True)
EOF
```{{execute T2}}

### 2. Crear el script `reducer.py`
Ahora crearemos el Reducer en la **Terminal 2**, el cual mantiene un diccionario en memoria RAM acumulando los conteos por cada ventana e imprime un corte cada 5 errores detectados:

```bash
cat << 'EOF' > /root/lab-streaming/reducer.py
import sys
from collections import defaultdict

conteos = defaultdict(int)
errores_procesados = 0

print("🎧 Consumidor Mapper/Reducer escuchando el flujo en vivo...\n", flush=True)

for linea in sys.stdin:
    linea = linea.strip()
    if not linea:
        continue
    clave, valor = linea.split("\t")
    conteos[clave] += int(valor)
    errores_procesados += 1

    if errores_procesados % 5 == 0:
        print(f"\n--- [REDUCER: Corte tras {errores_procesados} errores] (Ventanas en RAM: {len(conteos)}) ---")
        for k, v in sorted(conteos.items())[-8:]:
            ventana, ruta, status = k.split("|")
            print(f"Ventana: {ventana}s | Ruta: {ruta:<15} | HTTP {status} | Conteo: {v}", flush=True)
EOF
```{{execute T2}}

### 3. Conectar el flujo continuo con `tail -f`
Ejecuta la tubería Unix en la **Terminal 2** para acoplar el archivo en vivo con tu Mapper y Reducer:

```bash
tail -f /tmp/stream_logs.csv | python3 /root/lab-streaming/mapper.py | python3 /root/lab-streaming/reducer.py
```{{execute T2}}

### 🔍 Análisis de Ingeniería (Observa la salida durante 30 segundos):
1. Mira el indicador `(Ventanas en RAM: X)` en el encabezado de cada corte. Notarás que **el número de ventanas almacenadas en el diccionario `conteos` crece sin parar**.
2. ¿Por qué ocurre esto? Porque si un evento tardío (`-8s` o `-35s`) llega después, el Reducer necesita tener la ventana antigua en memoria para sumarle `+1`. Pero como no hemos definido una regla para **purgar ventanas viejas**, en un entorno de producción este script terminaría derribando el servidor por falta de memoria (`OutOfMemoryError`).

Detén el consumidor en la **Terminal 2** antes de pasar a la Fase 3 presionando `Ctrl + C`.