### Fase 4: Rescate de Datos (El Rollback)

El Nodo 1 se acaba de encender. Al contactar al clúster, descubre que el Nodo 2 es el líder y que sus historiales no coinciden.

Para no corromper la base de datos general, el Nodo 1 hace un Rollback: Elimina de su memoria el dato "FANTASMA" para poder sincronizarse con el Nodo 2.

¿Pero qué pasa con ese dato de telemetría? MongoDB no lo elimina para siempre. Lo resguarda en el sistema de archivos de Linux.

Vamos a explorar nuestro volumen de datos mapeado localmente en /root/data/nodo1/rollback/:

```bash
ls -lh data/nodo1/rollback/
```{{execute}}

¡Ahí está! Un archivo `.bson` generado automáticamente con nuestra telemetría huérfana.

Como arquitectos, podemos usar la utilidad `bsondump` para leer ese archivo binario e inspeccionar el dato que se descartó durante la partición de red:

```bash
docker exec -i ecorutas-nodo1 sh -c 'bsondump /data/db/rollback/ecorutas_db.telemetria*.bson'
```{{execute}}

Verás impreso en pantalla el documento `{ vehiculo_id: "FANTASMA", ... }`. Si este dato fuera crucial, ahora podrías re-insertarlo manualmente en el clúster.
