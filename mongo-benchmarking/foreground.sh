#!/bin/bash
clear
echo "=================================================================="
echo " Preparando el laboratorio de Benchmarking NoSQL..."
echo " Instalando Redis, MongoDB y configurando WiredTiger a 256 MB."
echo " Por favor espera unos segundos..."
echo "=================================================================="

while [ ! -f /tmp/setup_finished ]; do
    echo -n "."
    sleep 2
done

echo ""
echo "✅ ¡Entorno listo! Motores activos y calibrados para el benchmark."
cd /root/benchmark