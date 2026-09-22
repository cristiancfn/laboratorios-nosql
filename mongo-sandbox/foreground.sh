#!/bin/bash
clear
echo "Instalando y configurando MongoDB de forma nativa..."
echo "⚠️ NOTA: Es posible que veas una advertencia roja en la pantalla indicando que el script ha fallado o tardado demasiado."
echo "Por favor ignórala. La instalación sigue en curso en segundo plano."
echo ""
echo -n "Configurando"

while [ ! -f /tmp/finished ]; do
  echo -n "."
  sleep 2
done

clear
echo "¡El entorno está listo para usarse! 🚀"
echo "Servicio mongod en ejecución."
echo ""