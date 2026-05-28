#!/bin/bash

#Este script se ejecuta invisiblemente apenas el alumno entra al escenario.

#1. Levantar MongoDB 7.0 usando Docker con Replica Set habilitado (--replSet rs0)

docker run -d --name mongodb -p 27017:27017 mongo:7.0 --replSet rs0

#2. Esperar a que el demonio de Mongo esté listo para recibir conexiones

sleep 10

#3. Inicializar el Replica Set (Requisito estricto para transacciones)

docker exec mongodb mongosh --eval "rs.initiate()"

#4. Crear un alias global de 'mongosh' para que el alumno no tenga que escribir comandos docker

echo -e '#!/bin/bash\ndocker exec -it mongodb mongosh "$@"' > /usr/local/bin/mongosh
chmod +x /usr/local/bin/mongosh

#5. Bandera de finalización para liberar la terminal del alumno

touch /tmp/scenario-ready