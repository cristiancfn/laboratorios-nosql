### Fase 2: Inicialización del Clúster PSA y Gobernanza de Elecciones

Actualmente los tres procesos `mongod` están encendidos, pero aún no se conocen entre sí. Vamos a conectarnos a `nodo1:27017` usando `mongosh` para inicializar la topología **PSA (Primario - Secundario - Árbitro)**:

```bash
mongosh --host nodo1 --port 27017
```{{execute}}

#### Paso 1: Ejecutar `rs.initiate()` con Prioridades
En un clúster de producción no queremos que cualquier nodo gane la elección al azar si nuestro servidor principal está disponible. Configuraremos:
* **`nodo1:27017`** con `priority: 2` (Candidato preferido para ser Primario).
* **`nodo2:27018`** con `priority: 1` (Secundario estándar elegible en caso de desastre).
* **`arbitro:27019`** con `arbiterOnly: true` (Prioridad 0 implícita: vota en elecciones para dar quórum de 2/3, pero jamás puede ser Primario).

Ejecuta el bloque de inicialización dentro de `mongosh`:

```javascript
rs.initiate({
  _id: "rsProyecto",
  members: [
    { _id: 0, host: "nodo1:27017", priority: 2 },
    { _id: 1, host: "nodo2:27018", priority: 1 },
    { _id: 2, host: "arbitro:27019", arbiterOnly: true }
  ]
})
```{{execute}}

---

#### Paso 2: Verificar el Consenso y los Roles
Espera unos 5 segundos para que los nodos intercambien *heartbeats* y realicen la primera elección. Presiona **Enter** o ejecuta `db.hello()` para ver cómo el prompt cambió a `rsProyecto [direct: primary] test>`:

```javascript
db.hello()
```{{execute}}

Ahora revisemos la salud detallada de los miembros del clúster filtrando la salida de `rs.status()`:

```javascript
rs.status().members.map(m => ({
  id: m._id,
  host: m.name,
  estado: m.stateStr,
  salud: m.health
}))
```{{execute}}

Debes observar exactamente un `PRIMARY` (`nodo1`), un `SECONDARY` (`nodo2`) y un `ARBITER` (`arbitro`), todos con `salud: 1`.

Sal de la consola de `nodo1` para continuar a las pruebas de replicación e inspección forense:

```javascript
exit
```{{execute}}