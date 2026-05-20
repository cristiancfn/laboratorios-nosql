### Fase 4: Restauración del Sistema

Afortunadamente, seguimos las mejores prácticas de arquitectura y generamos un backup a tiempo.

Para recuperar la información, utilizaremos la herramienta mongorestore, apuntando al directorio BSON que guardamos en nuestro servidor Linux.

Haz clic para iniciar el proceso de restauración:

```bash
docker exec -it ecorutas_mongo mongorestore --nsInclude="ecorutas_db.*" /backups/emergencia/
```{{execute}}

Revisemos si el milagro ocurrió. Verifiquemos nuevamente la cantidad de registros en la base de datos de producción:

```bash
docker exec -it ecorutas_mongo mongosh --eval "db.getSiblingDB('ecorutas_db').telemetria.countDocuments()"
```{{execute}}

¡Operación salvada! Has recuperado los 10,000 registros en cuestión de segundos.