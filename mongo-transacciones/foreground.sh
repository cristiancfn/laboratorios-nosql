#!/bin/bash

echo "====================================================="
echo "Configurando la arquitectura del servidor MongoDB..."
echo "====================================================="
echo ""
echo "Por favor, espera unos segundos mientras se inicializa el Replica Set (rs0)."
echo "Esto es un requisito estricto para habilitar transacciones ACID en MongoDB."
echo ""

while [ ! -f /tmp/scenario-ready ]; do sleep 1; done

clear

echo "====================================================="
echo "Servidor Linux y MongoDB (versión 7.0) listos."
echo "Replica Set (rs0) inicializado correctamente."
echo "====================================================="
echo ""
echo "Ya puedes continuar con el laboratorio ejecutando los comandos."