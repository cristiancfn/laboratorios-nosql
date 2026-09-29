#!/bin/bash
# Este script retiene la terminal del usuario hasta que el background.sh termina de instalar Hadoop.

echo "=========================================================="
echo "Bienvenido al Laboratorio Arquitectónico de HDFS"
echo "=========================================================="
echo ""
echo "Orquestando el hardware y levantando la JVM de Hadoop..."
echo "Descargando Apache Hadoop 3.3.6 (Por favor espera unos 30-45 segundos)..."

# Esperar a que el archivo setup_done.txt sea creado por background.sh
while [ ! -f /root/setup_done.txt ]; do
    sleep 2
    echo -n "."
done

echo ""
echo "¡Inicialización Exitosa!"
echo "NameNode y DataNode están operativos."
echo "=========================================================="
source ~/.bashrc
# Limpiar pantalla para dar una experiencia prístina
sleep 2
clear