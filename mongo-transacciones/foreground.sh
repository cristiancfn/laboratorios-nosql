#!/bin/bash
# Limpiar la pantalla para una mejor experiencia visual
clear

echo -e "\e[1;34m=====================================================\e[0m"
echo -e "\e[1;37m🚀 Configurando la arquitectura del servidor MongoDB...\e[0m"
echo -e "\e[1;34m=====================================================\e[0m"
echo -e "\nPor favor, espera unos segundos mientras se inicializa el Replica Set (rs0)."
echo -e "Esto es un requisito estricto para habilitar transacciones ACID en MongoDB.\n"

while [ ! -f /tmp/scenario-ready ]; do sleep 1; done

clear
echo -e "\e[1;32m=====================================================\e[0m"
echo -e "\e[1;32m✅ Servidor Linux y MongoDB (versión 7.0) listos.\e[0m"
echo -e "\e[1;32m✅ Replica Set (rs0) inicializado correctamente.\e[0m"
echo -e "\e[1;32m=====================================================\e[0m"
echo -e "\nYa puedes continuar con el laboratorio ejecutando los comandos."
```