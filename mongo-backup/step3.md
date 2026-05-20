### Fase 3: Simulacro de Desastre

En la industria, los accidentes ocurren. Imagina que un desarrollador con privilegios excesivos se equivoca de entorno de producción y ejecuta un comando destructivo.

Vamos a simularlo. Primero, ingresa a la consola interactiva de MongoDB:

```bash
docker exec -it ecorutas_mongo mongosh
```{{execute}}

Ahora, selecciona la base de datos de telemetría y bórrala por completo haciendo clic en estos comandos:

```javascript
use ecorutas_db
```{{execute}}

```javascript
db.dropDatabase()
```{{execute}}

Verifica que la base de datos ya no existe en el sistema:

```javascript
show dbs
```{{execute}}

Sal de la consola de Mongo para planear la estrategia de recuperación:

```javascript
exit
```{{execute}}

La base de datos se ha esfumado. Los camiones a nivel nacional han perdido conexión. Avanza al siguiente paso para salvar la operación.