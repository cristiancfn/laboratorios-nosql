#!/bin/bash
clear
echo "=================================================================="
echo " Preparando el servidor Ubuntu para el laboratorio de Big Data..."
echo " (Instalando prerrequisitos base de red, OpenJDK y generando logs)"
echo "=================================================================="
while [ ! -f /tmp/background_ready ]; do
  echo -n "."
  sleep 2
done
echo ""
echo "¡Servidor listo! En /root encontrarás el binario de Hadoop y el archivo de logs."
echo "Ya puedes comenzar con el Paso 1."