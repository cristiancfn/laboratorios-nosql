#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Limpiar archivo testigo previo si existiera
rm -f /tmp/setup-finished

# Actualizar e instalar dependencias base
apt-get update -y
apt-get install -y gnupg curl ca-certificates lsb-release

# Importar llave GPG oficial de MongoDB 7.0
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Agregar repositorio oficial para Ubuntu Jammy (22.04) / Noble compatible
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Instalar MongoDB Server, Shell y Tools
apt-get update -y
apt-get install -y mongodb-org

# Detener y deshabilitar el servicio estándar para liberar el puerto 27017
systemctl stop mongod || true
systemctl disable mongod || true

# Señalizar finalización al foreground.sh
touch /tmp/setup-finished