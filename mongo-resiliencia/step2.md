### Fase 2: Auditoría Forense del Oplog

¿Cómo logró el Nodo 2 enterarse de los 10,000 registros insertados en el Nodo 1? A través del **Oplog (Operations Log)**, una colección especial de tamaño fijo (*capped collection*) ubicada en `local.oplog.rs` que guarda un historial ordenado e idempotente de cada cambio de estado.

Vamos a registrar un evento crítico individual en el Nodo Primario (`27017`) para rastrear su huella exacta en el Oplog. Ingresa a la consola interactiva del Primario:

```bash
mongosh --port 27017
```{{execute}}

Inserta el reporte de alerta de un camión con sobrecalentamiento severo:

```javascript
use ecorutas_db

db.telemetria.insertOne({
  vehiculo_id: "V-9999",
  temperatura_motor: 115,
  alerta: "Recalentamiento crítico de motor",
  fecha: new Date()
})
```{{execute}}

Ahora cambiemos a la base de datos interna `local` del motor para inspeccionar el último registro grabado en el Oplog:

```javascript
use local

db.oplog.rs.find({ 
  op: "i", 
  ns: "ecorutas_db.telemetria",
  "o.vehiculo_id": "V-9999"
}).sort({ $natural: -1 }).limit(1)
```{{execute}}

Observa detenidamente los campos de salida:
* **`ts` (Timestamp):** Marca de tiempo interna del clúster que determina el orden exacto de los eventos.
* **`t` (Term):** El período o mandato electoral en el que el líder actual fue elegido.
* **`op`:** Tipo de operación (`"i"` = *insert*, `"u"` = *update*, `"d"` = *delete*, `"c"` = *command*).
* **`ns` (Namespace):** La base de datos y colección afectadas (`ecorutas_db.telemetria`).
* **`o`:** El documento exacto con su `_id` ya calculado. **Esta es la fuente de la verdad del clúster.**

Sal de la consola de `mongosh` para continuar:

```javascript
exit
```{{execute}}