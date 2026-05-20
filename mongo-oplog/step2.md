### Fase 2: Inspección Forense del Oplog

Vamos a generar un evento crítico de telemetría directamente en el Nodo Primario. Ingresa a su consola:

```bash
docker exec -it ecorutas-nodo1 mongosh --port 27017
```{{execute}}

Inserta el reporte de un camión recalentado:

```javascript
use ecorutas_db

db.telemetria.insertOne({
  vehiculo_id: "V-9999",
  temperatura: 85,
  alerta: "Recalentamiento de motor",
  fecha: new Date()
})
```{{execute}}

Ahora, cambiaremos a la base de datos del sistema local para ver cómo MongoDB registró esta operación para replicarla a los demás nodos.

```javascript
use local

db.oplog.rs.find({ 
  op: "i", 
  ns: "ecorutas_db.telemetria" 
}).sort({ $natural: -1 }).limit(1)
```{{execute}}

Analiza la salida. Notarás el campo `ts` (Timestamp de 64 bits), la `op` ("i" de insert) y el campo `o` que contiene el documento exacto y su `_id` generado. **Esta es la verdadera fuente de la verdad de un clúster.**

Sal de la consola para continuar:

```javascript
exit
```{{execute}}