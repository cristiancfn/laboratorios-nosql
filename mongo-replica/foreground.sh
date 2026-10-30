#!/bin/bash

clear
echo "===================================================================="
echo " ⚙️  Preparando el servidor Linux e instalando MongoDB 7.0..."
echo "    Por favor espera unos 40-60 segundos antes de iniciar."
echo "===================================================================="

while [ ! -f /tmp/setup-finished ]; do
  echo -n "."
  sleep 2
done

echo ""
echo "✅ ¡Entorno listo! Versión instalada:"
mongod --version | head -n 1
echo "===================================================================="