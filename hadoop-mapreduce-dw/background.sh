#!/bin/bash

# 1. Actualizar repositorios e instalar OpenJDK 11 y utilidades necesarias
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y openjdk-11-jdk ssh pdsh curl wget python3

# 2. Generar el dataset crudo de logs transaccionales (50,000 registros con ruido)
cat << 'EOF' > /tmp/generate_logs.py
import random
from datetime import datetime, timedelta

tiendas = ["TIENDA_BOG_01", "TIENDA_BOG_02", "TIENDA_MED_01", "TIENDA_CAL_01", "TIENDA_BAQ_01"]
productos = [
    ("PROD_CAFE_500G", "BEBIDAS", 24500.00),
    ("PROD_PRENSA_FR", "ACCESORIOS", 68000.00),
    ("PROD_FILTRO_PAPEL", "ACCESORIOS", 12000.00),
    ("PROD_MOLINO_MAN", "EQUIPOS", 95000.00),
    ("PROD_TERMO_ACERO", "ACCESORIOS", 45000.00),
    ("PROD_CACAO_250G", "BEBIDAS", 18500.00)
]
metodos_pago = ["TARJETA_CREDITO", "TARJETA_DEBITO", "EFECTIVO", "TRANSFERENCIA_QR"]
estados = ["COMPLETED", "COMPLETED", "COMPLETED", "COMPLETED", "CANCELLED", "ERROR_TIMEOUT"]

base_date = datetime(2026, 10, 1)

with open("/root/raw_pos_transactions.log", "w") as f:
    for i in range(1, 50001):
        # Introducir 2% de registros corruptos o incompletos para que el Mapper los filtre
        if random.random() < 0.02:
            f.write(f"CORRUPTED_LINE|ERR_{i}|NULL_DATA\n")
            continue
        
        dt = base_date + timedelta(days=random.randint(0, 30), seconds=random.randint(0, 86399))
        fecha_str = dt.strftime("%Y-%m-%d %H:%M:%S")
        tienda = random.choice(tiendas)
        prod_id, categoria, precio_unit = random.choice(productos)
        cantidad = random.randint(1, 5)
        monto_total = round(cantidad * precio_unit, 2)
        
        # Introducir variaciones de formato en método de pago (minúsculas/espacios)
        metodo = random.choice(metodos_pago)
        if random.random() < 0.15:
            metodo = metodo.lower()
            
        estado = random.choice(estados)
        
        linea = f"{fecha_str}|{tienda}|{prod_id}|{categoria}|{cantidad}|{monto_total}|{metodo}|{estado}\n"
        f.write(linea)
EOF

python3 /tmp/generate_logs.py
rm /tmp/generate_logs.py

# 3. Pre-descargar Apache Hadoop 3.3.6 en /root/ para que el estudiante lo instale sin esperar la descarga
wget -q https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz -O /root/hadoop-3.3.6.tar.gz

# 4. Marcar fin del aprovisionamiento
touch /tmp/background_ready