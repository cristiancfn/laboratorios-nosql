#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# 1. Actualizar e instalar paquetes base y Redis
apt-get update
apt-get install -y curl gnupg lsb-release redis-server python3-pip bc

# 2. Instalar MongoDB 7.0 si no está preinstalado
if ! command -v mongod &> /dev/null; then
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    apt-get update
    apt-get install -y mongodb-org
fi

# 3. Instalar drivers de Python para el generador de concurrencia (Etapa 3)
pip3 install pymongo redis

# 4. Configurar y arrancar Redis (limitado a 64MB para proteger la VM)
systemctl stop redis-server
redis-server --daemonize yes --maxmemory 64mb --maxmemory-policy allkeys-lru

# 5. Configurar y arrancar MongoDB con caché de WiredTiger limitada a 256MB (0.25 GB)
systemctl stop mongod || true
mkdir -p /data/bench_db /var/log/mongodb
chown -R mongodb:mongodb /data/bench_db /var/log/mongodb

mongod --dbpath /data/bench_db \
       --logpath /var/log/mongodb/mongod.log \
       --wiredTigerCacheSizeGB 0.25 \
       --bind_ip 127.0.0.1 \
       --port 27017 \
       --fork

# 6. Crear directorio de trabajo y scripts de apoyo para las pruebas
mkdir -p /root/benchmark

cat << 'EOF' > /root/benchmark/scale_test.py
import sys
import time
import random
from concurrent.futures import ThreadPoolExecutor
from pymongo import MongoClient

threads = int(sys.argv[1]) if len(sys.argv) > 1 else 1
ops_per_thread = int(sys.argv[2]) if len(sys.argv) > 2 else 1000

client = MongoClient("mongodb://127.0.0.1:27017/", maxPoolSize=threads + 10)
col = client.bench.lecturas_escala

def worker(worker_id):
    latencies = []
    for _ in range(ops_per_thread):
        sensor_buscado = random.randint(1, 500)
        t0 = time.perf_counter()
        # Consulta por rango que exige trabajo de CPU y lectura de índice
        list(col.find({"sensor_id": sensor_buscado, "temperatura": {"$gt": 25}}).limit(5))
        t1 = time.perf_counter()
        latencies.append((t1 - t0) * 1000.0) # en ms
    return latencies

print(f"\n[SCALING] Ejecutando prueba con {threads} hilo(s) concurrente(s) ({threads * ops_per_thread} consultas totales)...")
start_total = time.perf_counter()

all_latencies = []
with ThreadPoolExecutor(max_workers=threads) as executor:
    futures = [executor.submit(worker, i) for i in range(threads)]
    for f in futures:
        all_latencies.extend(f.result())

end_total = time.perf_counter()
total_time = end_total - start_total
total_ops = len(all_latencies)
all_latencies.sort()

avg_lat = sum(all_latencies) / total_ops
p95_lat = all_latencies[int(total_ops * 0.95)]
p99_lat = all_latencies[int(total_ops * 0.99)]
tps = total_ops / total_time

print("-" * 60)
print(f"Hilos concurrentes : {threads}")
print(f"Tiempo total       : {total_time:.2f} s")
print(f"Throughput (QPS)   : {tps:.2f} consultas/seg")
print(f"Latencia Promedio  : {avg_lat:.2f} ms")
print(f"Latencia p95       : {p95_lat:.2f} ms")
print(f"Latencia p99       : {p99_lat:.2f} ms")
print("-" * 60)
EOF

chmod +x /root/benchmark/scale_test.py

# Marcar finalización para foreground.sh
touch /tmp/setup_finished