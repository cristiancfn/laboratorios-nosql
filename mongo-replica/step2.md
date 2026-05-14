### Fase 2: Configuración del Clúster y Tolerancia a Fallos

Los contenedores están listos, pero son independientes. Ingresa a la consola del primer nodo:

```bash
docker exec -it nodo-primario mongosh
```{{execute}}

Ejecuta el siguiente comando para inicializar el Replica Set:

```javascript
rs.initiate(
  {
    _id: "mi_cluster",
    members: [
      { _id: 0, host: "nodo-primario:27017" },
      { _id: 1, host: "nodo-secundario-1:27017" },
      { _id: 2, host: "nodo-secundario-2:27017" }
    ]
  }
)
```{{execute}}

Presiona la tecla **Enter** un par de veces en la terminal. Verás que tu prompt cambia para indicar que este nodo es ahora el `PRIMARY`. Revisa el estado del clúster:

```javascript
rs.status()
```{{execute}}

¡Vamos a probar la tolerancia a fallos! Primero, inserta un documento de prueba:

```javascript
db.laboratorio.insertOne({ mensaje: "Prueba de alta disponibilidad en curso" })
```{{execute}}

Sal de la consola de Mongo:

```javascript
exit
```{{execute}}

Ahora, simularemos una caída catastrófica apagando el contenedor del servidor principal:

```bash
docker stop nodo-primario
```{{execute}}

Ingresa rápidamente a la consola de uno de los nodos restantes:

```bash
docker exec -it nodo-secundario-1 mongosh
```{{execute}}

Vuelve a revisar el estado. ¡Verás que los nodos sobrevivientes hicieron una elección y hay un nuevo PRIMARY!

```javascript
rs.status()
```{{execute}}