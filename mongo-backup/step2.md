### Fase 2: Creación del Backup Lógico (El Volcado)

La base de datos está operativa, pero actualmente somos vulnerables. Si ocurre un error, perderemos todo.

Vamos a utilizar la herramienta mongodump ejecutándola dentro del contenedor de Docker, pero guardaremos el resultado en la carpeta /backups (la cual está mapeada de forma segura a nuestro servidor Linux anfitrión en ./mis_backups).

Ejecuta el volcado de datos:

```bash
docker exec -it ecorutas_mongo mongodump --db=ecorutas_db --out=/backups/emergencia
```{{execute}}

Verifiquemos que los archivos BSON (Binary JSON) se han guardado exitosamente en el disco duro de nuestro servidor Linux:

```bash
ls -lh mis_backups/emergencia/ecorutas_db/
```{{execute}}

¡Excelente! La información de EcoRutas Logistics ahora tiene un respaldo físico seguro.