#!/bin/bash
# Importar la llave pública y añadir el repositorio (MongoDB 7.0)
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Actualizar repositorios e instalar MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Iniciar el servicio y habilitarlo
sudo systemctl start mongod
sudo systemctl enable mongod

# Archivo bandera para indicar a Killercoda que la instalación finalizó
touch /tmp/finished