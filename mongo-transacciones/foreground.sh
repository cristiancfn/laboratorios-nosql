#!/bin/bash

#Muestra un mensaje amigable mientras el background.sh termina de configurar el Replica Set

echo "Configurando la arquitectura del servidor MongoDB (Replica Set)..."
echo "Por favor, espera unos segundos..."

while [ ! -f /tmp/scenario-ready ]; do
  sleep 1
done

clear
echo "====================================================="
echo "✅ Servidor Linux y MongoDB listos."
echo "✅ Replica Set (rs0) inicializado."
echo "====================================================="
echo " "
echo "Ya puedes continuar con el laboratorio."