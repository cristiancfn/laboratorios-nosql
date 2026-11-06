#!/bin/bash

clear
echo "===================================================================="
echo " ⚙️  Preparando el servidor Linux e instalando MongoDB 7.0 + Tools..."
echo "    Por favor espera unos 40-60 segundos antes de iniciar."
echo "===================================================================="

while [ ! -f /tmp/setup-finished ]; do
  echo -n "."
  sleep 2
done

echo ""
echo "✅ ¡Entorno listo! Herramientas instaladas:"
mongod --version | head -n 1
mongodump --version | head -n 1
echo "===================================================================="