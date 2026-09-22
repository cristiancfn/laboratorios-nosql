#!/bin/bash
clear
echo "Instalando y configurando MongoDB de forma nativa..."
echo "Por favor espera unos segundos. La terminal se habilitará automáticamente."
echo ""

# Este bucle pausa la terminal hasta que background.sh cree el archivo bandera
while [ ! -f /tmp/finished ]; do
  sleep 1
done

clear
echo "¡El entorno está listo para usarse! 🚀"
echo "Servicio mongod en ejecución."
echo ""