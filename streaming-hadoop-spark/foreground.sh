#!/bin/bash
clear
echo "=================================================================="
echo " Preparando el entorno de Big Data y Streaming (Java + PySpark)..."
echo " Por favor espera unos segundos mientras se configuran los paquetes."
echo "=================================================================="

while [ ! -f /tmp/setup_finished ]; do
  echo -n "."
  sleep 2
done

echo ""
echo "✅ ¡Entorno listo! Ya puedes comenzar con la Fase 1."
cd /root/lab-streaming