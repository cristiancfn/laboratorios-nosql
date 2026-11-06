### Fase 3: Desastre Humano, Backup Lógico y Restauración

Un error común en arquitectura es pensar que tener un *Replica Set* reemplaza a las copias de respaldo (Backups). Sin embargo, si alguien ejecuta por error un comando destructivo en el Primario, **ese comando viajará por el Oplog en milisegundos y destruirá también los datos en el Secundario**.

#### 1. Creación preventiva del Backup Lógico (`mongodump`)
Antes de que ocurra una tragedia, generaremos un volcado binario (`.bson`) de nuestra base de datos de producción (`10,001` documentos en total) hacia el directorio `/backups/emergencia` de nuestro servidor:

```bash
mongodump --host 127.0.0.1 --port 27017 --db=ecorutas_db --out=/backups/emergencia
```{{execute}}

Comprobemos que los archivos `.bson` (datos binarios) y `.metadata.json` (índices y opciones) existen en nuestro disco duro:

```bash
ls -lh /backups/emergencia/ecorutas_db/
```{{execute}}

#### 2. Simulacro de Desastre Humano
Imagina que un ingeniero ejecuta por accidente un script de limpieza conectado al entorno de producción. Simulemos ese error borrando la base de datos en el Primario:

```bash
mongosh --port 27017 --eval "db.getSiblingDB('ecorutas_db').dropDatabase()"
```{{execute}}

Verifiquemos qué ocurrió tanto en el Primario (`27017`) como en el Secundario (`27018`):

```bash
echo "Documentos en Primario (27017):"
mongosh --port 27017 --quiet --eval "db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"

echo "Documentos en Secundario (27018):"
mongosh --port 27018 --quiet --eval "db.getMongo().setReadPref('secondary'); db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"
```{{execute}}

¡Ambos devuelven `0`! El comando `dropDatabase` se replicó por el Oplog e impactó a todo el clúster al instante.

#### 3. Restauración del Sistema (`mongorestore`)
Gracias a nuestro respaldo lógico en disco, podemos reconstruir toda la colección inyectando los archivos BSON nuevamente en el nodo Primario:

```bash
mongorestore --host 127.0.0.1 --port 27017 --nsInclude="ecorutas_db.*" /backups/emergencia/
```{{execute}}

Comprobemos que los **10,001 documentos** (los 10,000 iniciales más la alerta `V-9999`) han vuelto a la vida en ambos nodos del clúster:

```bash
echo "Documentos recuperados en Primario (27017):"
mongosh --port 27017 --quiet --eval "db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"

echo "Documentos replicados en Secundario (27018):"
mongosh --port 27018 --quiet --eval "db.getMongo().setReadPref('secondary'); db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"
```{{execute}}