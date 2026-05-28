# Fase 2: Auditoría con Database Profiler

Al tener un volumen grande de datos, hacer consultas sin índices obliga a la RAM del servidor Linux a cargar cada uno de los 100,000 documentos para buscar el que necesitas.

### 1\. Habilitar la Auditoría

Le pediremos al motor que registre cualquier consulta que tarde más de 20 milisegundos.

```javascript
db.setProfilingLevel(1, { slowms: 20 })
```{{execute}}

### 2\. Forzar un Cuello de Botella

Vamos a buscar la transferencia número 99999. Como no hay un índice, esto será dolorosamente ineficiente para el motor.

```javascript
db.historial.find({ numero_transferencia: 99999 })
```{{execute}}

### 3\. Leer el Profiler

Veamos qué "atrapó" nuestra herramienta de auditoría leyendo la colección oculta system.profile:

```javascript
db.system.profile.find(
  { "command.filter.numero_transferencia": 99999 },
  { millis: 1, planSummary: 1, docsExamined: 1, _id: 0 }
).pretty()
```{{execute}}

**¡Analiza la salida!**
* `planSummary: "COLLSCAN"`: (Collection Scan) El motor tuvo que escanear toda la colección a ciegas.
* `docsExamined: 100000`: Revisó 100 mil documentos para devolverte solo 1.

### 4\. Resolución Arquitectónica
Creamos un índice en memoria utilizando un B-Tree:

```javascript
db.historial.createIndex({ numero_transferencia: 1 })
```{{execute}}

Ejecutemos la consulta de nuevo:
```javascript
db.historial.find({ numero_transferencia: 99999 })
```{{execute}}

Y volvamos a revisar el Profiler para esa nueva ejecución (esta vez tardará 0 o 1 millisegundo):
```javascript
db.system.profile.find(
  { "command.filter.numero_transferencia": 99999 },
  { millis: 1, planSummary: 1, docsExamined: 1, _id: 0 }
).sort({$natural: -1}).limit(1).pretty()
```{{execute}}

*¡Felicidades! Pasaste de un `COLLSCAN` destructivo a un `IXSCAN` eficiente examinando solo 1 documento.*
