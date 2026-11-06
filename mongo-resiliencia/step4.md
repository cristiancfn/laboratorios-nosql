### Fase 4: Simulacro de Split-Brain (Cerebro Dividido)

Ahora nos enfrentaremos a un fallo de infraestructura mucho más sutil que un borrado humano: una **divergencia de historias (Split-Brain)**.

#### 1. Caída del Nodo Secundario
Simularemos que el Nodo 2 (`27018`) pierde conexión total cerrando su proceso abruptamente. El Nodo 1 y el Árbitro seguirán operando:

```bash
kill -9 $(pgrep -f "port 27018")
```{{execute}}

#### 2. Escritura aislada en el Nodo 1 (El dato "FANTASMA")
Aunque el Nodo 2 está apagado, **el Nodo 1 (`27017`) sigue siendo Primario legítimo** porque conserva la mayoría de votos junto al Árbitro (`27017` + `27019` = 2 de 3 votos).
Insertaremos un nuevo registro de telemetría en el Nodo 1 confirmando la escritura localmente (`w: 1`). Como el Nodo 2 está apagado, **es físicamente imposible que reciba este dato**:

```bash
mongosh --port 27017 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne(
  { vehiculo_id: "FANTASMA", nota: "Dato huérfano escrito únicamente en Nodo 1 antes del apagón." },
  { writeConcern: { w: 1 } }
)'
```{{execute}}

#### 3. Caída súbita del Nodo 1 y ascenso del Nodo 2
En este preciso instante, el servidor del Nodo 1 sufre un corte eléctrico abrupto (`kill -9`):

```bash
kill -9 $(pgrep -f "port 27017")
```{{execute}}

Con el Nodo 1 fuera de combate, el equipo de infraestructura logra levantar nuevamente el Nodo 2 (`27018`):

```bash
mongod --replSet ecorutas-rs --port 27018 --bind_ip 127.0.0.1 --dbpath /datos/nodo2 --logpath /datos/nodo2/mongod.log --oplogSize 128 --fork
```{{execute}}

Esperemos 12 segundos para que el Nodo 2 contacte al Árbitro (`27019`), gane la elección por mayoría (2 de 3 votos) y se convierta en el **nuevo Primario**. En esta nueva realidad, un camión reporta un dato distinto (`"REAL"`):

```bash
sleep 12 && mongosh --port 27018 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne(
  { vehiculo_id: "REAL", nota: "Nueva línea temporal autorizada por el nuevo Primario (Nodo 2)." },
  { writeConcern: { w: 1 } }
)'
```{{execute}}

**Analiza el conflicto arquitectónico que acabamos de crear:**
* El **Nodo 1** (apagado) tiene en su disco el documento `vehiculo_id: "FANTASMA"`, escrito en el mandato electoral anterior.
* El **Nodo 2** (actual Primario) jamás estuvo encendido cuando se escribió `"FANTASMA"`, inició un nuevo mandato electoral y avanzó su Oplog con `vehiculo_id: "REAL"`.

Avanza a la última fase para encender el Nodo 1 y descubrir cómo resuelve MongoDB esta paradoja.