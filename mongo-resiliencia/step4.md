### Fase 4: Simulacro de Split-Brain (Cerebro Dividido)

Ahora nos enfrentaremos a un fallo de infraestructura mucho más sutil que un borrado humano: una **divergencia de historias (Split-Brain)**.

#### 1. Aislamiento del Nodo Secundario
Simularemos una saturación crítica o congelamiento de red en el Nodo 2 (`27018`) enviándole la señal POSIX `SIGSTOP` en el kernel de Linux. El proceso seguirá existiendo en memoria, pero quedará totalmente incomunicado del clúster:

```bash
kill -STOP $(pgrep -f "port 27018")
```{{execute}}

#### 2. Escritura aislada en el Nodo 1 (El dato "FANTASMA")
Aunque el Nodo 2 no responde, **el Nodo 1 (`27017`) sigue siendo Primario legítimo** porque conserva la mayoría de votos junto al Árbitro (`27017` + `27019` = 2 de 3 votos).
Insertaremos un nuevo registro de telemetría en el Nodo 1, el cual **no podrá replicarse al Nodo 2** porque está congelado:

```bash
mongosh --port 27017 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne({
  vehiculo_id: "FANTASMA",
  nota: "Dato huérfano escrito únicamente en Nodo 1 antes del apagón."
})'
```{{execute}}

#### 3. Caída súbita del Nodo 1 y ascenso del Nodo 2
En este preciso instante, el servidor del Nodo 1 sufre un corte eléctrico abrupto (`kill -9`) antes de poder sincronizar el dato `"FANTASMA"`:

```bash
kill -9 $(pgrep -f "port 27017")
```{{execute}}

Inmediatamente después, la comunicación con el Nodo 2 (`27018`) se restablece (`SIGCONT`):

```bash
kill -CONT $(pgrep -f "port 27018")
```{{execute}}

Esperemos 12 segundos para que el Nodo 2 y el Árbitro detecten la ausencia del Nodo 1 y elijan al **Nodo 2 como nuevo Primario** del clúster. Una vez elegido, un camión reportará un dato completamente distinto en esta nueva línea temporal:

```bash
sleep 12 && mongosh --port 27018 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne({
  vehiculo_id: "REAL",
  nota: "Nueva línea temporal autorizada por el nuevo Primario (Nodo 2)."
})'
```{{execute}}

**Analiza el conflicto arquitectónico que acabamos de crear:**
* El **Nodo 1** (apagado) cree que el último dato válido del universo es `vehiculo_id: "FANTASMA"`.
* El **Nodo 2** (actual Primario) nunca conoció a `"FANTASMA"` y avanzó su propio Oplog con `vehiculo_id: "REAL"`.

Avanza a la última fase para encender el Nodo 1 y descubrir cómo resuelve MongoDB esta paradoja.