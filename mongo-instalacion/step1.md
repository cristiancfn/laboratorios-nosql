Para instalar MongoDB en Ubuntu, primero debemos importar la llave GPG pública y añadir el repositorio oficial.

Importa la llave pública de MongoDB:
`curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor`{{execute}}

Crea el archivo de lista para MongoDB:
`echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list`{{execute}}

Actualiza la base de datos de paquetes locales e instala MongoDB:
`sudo apt-get update && sudo apt-get install -y mongodb-org`{{execute}}