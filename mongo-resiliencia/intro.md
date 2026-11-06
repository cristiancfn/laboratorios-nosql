# Laboratorio: Arquitectura de Resiliencia, Oplog, Backups y Rollbacks

Bienvenido a este entorno práctico de arquitectura de bases de datos NoSQL.

### Contexto del Caso: EcoRutas Logistics
En este escenario asumirás el rol de **Arquitecto de Datos Principal en EcoRutas Logistics**, una compañía de transporte de carga y cadena de frío que monitorea en tiempo real una flota nacional de camiones mediante sensores IoT. Cada vehículo reporta constantemente la velocidad, ubicación y temperatura del motor hacia nuestra base de datos `ecorutas_db`.

Como responsable de la continuidad del negocio, debes garantizar que la plataforma sobreviva a dos de las amenazas más críticas en sistemas distribuidos:
1. **Errores humanos destructivos** (como borrar por accidente una base de datos en producción).
2. **Fallos de infraestructura y particiones de red** (escenarios de *Split-Brain* o "Cerebro Dividido" donde distintos nodos aceptan datos contradictorios).

### ¿Qué haremos en este laboratorio?
* Desplegaremos un clúster distribuido (*Replica Set*) de 3 nodos corriendo procesos `mongod` nativos en Linux (**Primario**, **Secundario** y **Árbitro**) e inyectaremos **10,000 registros de telemetría**.
* Auditaremos a bajo nivel la colección `local.oplog.rs` para comprender cómo MongoDB replica operaciones de forma idempotente.
* Demostraremos por qué **la replicación no reemplaza a un backup**, ejecutando copias de respaldo lógicas con `mongodump` y restaurando el clúster tras un borrado total con `mongorestore`.
* Provocaremos un conflicto de *Split-Brain* congelando procesos en el kernel de Linux para forzar historias divergentes entre nodos.
* Observaremos cómo MongoDB se auto-sana ejecutando un **Rollback** automático y rescataremos los datos descartados usando análisis forense con `bsondump`.

Espera a que la terminal indique **`✅ ¡Entorno listo!`** y avanza a la primera fase.