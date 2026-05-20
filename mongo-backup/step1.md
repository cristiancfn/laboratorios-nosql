### Fase 1: Despliegue y Población de Datos

Primero, crearemos la infraestructura básica y el script que generará nuestra telemetría. Haz clic en el siguiente bloque para crear los archivos necesarios:

```bash
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
mongodb:
image: mongo:7.0
container_name: ecorutas_mongo
restart: always
ports:
- "27017:27017"
volumes:
- ./mis_backups:/backups
EOF

cat << 'EOF' > poblar_datos.js
use ecorutas_db;
print("Iniciando la inserción de 10.000 registros de telemetría...");
let batch = [];
for (let i = 1; i <= 10000; i++) {
batch.push({
vehiculo_id: "TRK-" + (Math.floor(Math.random() * 500) + 1000),
fecha: new Date(),
velocidad: Math.floor(Math.random() * 100),
temperatura_motor: 85 + Math.floor(Math.random() * 20)
});
if (i % 1000 === 0) {
db.telemetria.insertMany(batch);
batch = [];
}
}
print("¡Base de datos EcoRutas poblada con éxito!");
EOF
```{{execute}}

Ahora, levanta el contenedor de MongoDB en segundo plano:

```bash
docker-compose up -d
```{{execute}}

Esperemos un par de segundos a que el motor inicie y luego inyectemos los 10,000 registros utilizando el script que creamos:

```bash
sleep 3 && cat poblar_datos.js | docker exec -i ecorutas_mongo mongosh --quiet
```{{execute}}

Comprobemos que los datos están ahí consultando el total de documentos:

```bash
docker exec -it ecorutas_mongo mongosh --eval "db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"
```{{execute}}