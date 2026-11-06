### Fase 1: Topología del Clúster y Población de Datos

Comenzaremos levantando nuestra arquitectura de alta disponibilidad directamente sobre el sistema operativo Linux. Nuestro Replica Set (`ecorutas-rs`) estará compuesto por tres procesos independientes:
* **Nodo 1 (Puerto `27017`):** Candidato principal a **Primario** (Prioridad 2).
* **Nodo 2 (Puerto `27018`):** Nodo **Secundario** de respaldo de datos (Prioridad 1).
* **Nodo Árbitro (Puerto `27019`):** Nodo ligero sin copia de datos, cuya única misión es desempatar votaciones para mantener la mayoría (quórum).

Inicia los tres procesos `mongod` en segundo plano (`--fork`):

```bash
mongod --replSet ecorutas-rs --port 27017 --bind_ip 127.0.0.1 --dbpath /datos/nodo1 --logpath /datos/nodo1/mongod.log --oplogSize 128 --fork
mongod --replSet ecorutas-rs --port 27018 --bind_ip 127.0.0.1 --dbpath /datos/nodo2 --logpath /datos/nodo2/mongod.log --oplogSize 128 --fork
mongod --replSet ecorutas-rs --port 27019 --bind_ip 127.0.0.1 --dbpath /datos/arbitro --logpath /datos/arbitro/mongod.log --oplogSize 128 --fork
```{{execute}}

Ahora, conéctate al Nodo 1 (`27017`) para inicializar el Replica Set y definir las prioridades de elección:

```bash
mongosh --port 27017 --eval 'rs.initiate({
  _id: "ecorutas-rs",
  members: [
    { _id: 0, host: "127.0.0.1:27017", priority: 2 },
    { _id: 1, host: "127.0.0.1:27018", priority: 1 },
    { _id: 2, host: "127.0.0.1:27019", arbiterOnly: true }
  ]
})'
```{{execute}}

Esperemos 5 segundos a que la elección concluya y el Nodo 1 asuma como `PRIMARY`. A continuación, generaremos e inyectaremos el lote inicial de **10,000 registros de telemetría** de la flota de camiones:

```bash
cat << 'EOF' > poblar_datos.js
use ecorutas_db;
print("Iniciando la inserción de 10,000 registros de telemetría...");
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

sleep 5 && mongosh --port 27017 --quiet < poblar_datos.js
```{{execute}}

Verifiquemos que los 10,000 documentos se escribieron en el Primario (`27017`) y se replicaron automáticamente en el Secundario (`27018`):

```bash
echo "Documentos en Primario (27017):"
mongosh --port 27017 --quiet --eval "db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"

echo "Documentos en Secundario (27018):"
mongosh --port 27018 --quiet --eval "db.getMongo().setReadPref('secondary'); db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"
```{{execute}}

Ambos nodos de datos cuentan exactamente con los mismos 10,000 registros.