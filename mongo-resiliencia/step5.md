### Fase 5: Autosanación (Rollback) y Rescate Forense BSON

Vamos a encender nuevamente el proceso del Nodo 1 (`27017`) para que se reincorpore al clúster:

```bash
mongod --replSet ecorutas-rs --port 27017 --bind_ip 127.0.0.1 --dbpath /datos/nodo1 --logpath /datos/nodo1/mongod.log --oplogSize 128 --fork
```{{execute}}

Esperemos 8 segundos mientras el Nodo 1 contacta al Nodo 2 (`27018`). Al comparar sus Oplogs, el Nodo 1 descubre que el Nodo 2 tiene un mandato electoral superior y un historial que diverge del suyo.

Para no corromper la integridad del clúster, **el Nodo 1 ejecuta automáticamente un Rollback**: revierte su propia escritura (`"FANTASMA"`) y adopta la línea temporal del Nodo 2 (`"REAL"`). Verifiquémoslo consultando ambos documentos en el Nodo 1:

```bash
sleep 10
echo "¿Existe el vehículo REAL en el clúster?"
mongosh --port 27017 --quiet --eval 'db.getMongo().setReadPref("secondaryPreferred"); db.getSiblingDB("ecorutas_db").telemetria.findOne({vehiculo_id: "REAL"})'

echo "¿Existe el vehículo FANTASMA en el clúster?"
mongosh --port 27017 --quiet --eval 'db.getMongo().setReadPref("secondaryPreferred"); db.getSiblingDB("ecorutas_db").telemetria.findOne({vehiculo_id: "FANTASMA"})'
```{{execute}}

Verás que `"REAL"` ya se replicó al Nodo 1, mientras que `"FANTASMA"` devuelve `null`.

#### Rescate Forense del Dato Huérfano
¿Perdimos para siempre la telemetría del vehículo `"FANTASMA"`? **No.** MongoDB jamás destruye en silencio los datos descartados en un Rollback; los vuelca a una subcarpeta llamada `rollback/` dentro del `--dbpath` del nodo afectado (`/datos/nodo1/rollback/`).

Inspeccionemos el directorio de rollback en nuestro sistema de archivos Linux:

```bash
ls -lh /datos/nodo1/rollback/*/
```{{execute}}

¡Ahí está! Encontrarás un archivo binario `.bson` generado automáticamente por el motor de base de datos durante el conflicto.

Como arquitectos, utilizaremos la herramienta forense `bsondump` para decodificar ese archivo binario a formato JSON legible y recuperar la información descartada:

```bash
bsondump /datos/nodo1/rollback/*/*.bson
```{{execute}}

En tu pantalla aparecerá impreso el documento `{ vehiculo_id: "FANTASMA", nota: "Dato huérfano escrito únicamente en Nodo 1 antes del apagón." }`. Con este respaldo forense, el equipo de ingeniería puede auditar el evento y decidir si lo re-inserta manualmente en el clúster.