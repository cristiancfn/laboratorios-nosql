#!/bin/bash
# Este script se ejecuta de forma silenciosa e invisible en el entorno de Killercoda

# 1. Eliminar cualquier contenedor previo por si acaso y levantar MongoDB 7.0
docker rm -f mongodb 2>/dev/null
docker run -d --name mongodb -p 27017:27017 mongo:7.0 --replSet rs0

# 2. Bucle para asegurar que el demonio de Mongo esté listo para recibir conexiones
until docker exec mongodb mongosh --eval "print(\"waited for connection\")" &>/dev/null; do
    sleep 2
done

# 3. Inicializar el Replica Set (Requisito estricto para transacciones)
docker exec mongodb mongosh --eval "rs.initiate()" &>/dev/null

# Darle unos segundos adicionales al motor para que asuma el rol de PRIMARY
sleep 5

# 4. Crear un alias global de 'mongosh' para el alumno
echo -e '#!/bin/bash\ndocker exec -it mongodb mongosh "$@"' > /usr/local/bin/mongosh
chmod +x /usr/local/bin/mongosh

# 5. Crear la bandera de éxito para que foreground.sh libere la terminal
touch /tmp/scenario-ready
```