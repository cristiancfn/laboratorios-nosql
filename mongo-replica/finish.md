# ¡Laboratorio Completado con Éxito!

Has desplegado, diagnosticado y puesto a prueba una topología **Replica Set PSA** en Linux aplicando los mismos estándares de configuración que utilizarás en máquinas virtuales dedicadas.

### Resumen de Competencias Adquiridas:
* **Administración en Linux:** Configuración de resolución de nombres en `/etc/hosts`, aislamiento de directorios de datos (`dbPath`), ajuste de memoria de WiredTiger y despliegue de demonios con archivos YAML (`/etc/mongod*.conf`).
* **Gobernanza de Consenso:** Uso de `priority` para dirigir elecciones hacia el servidor principal y despliegue de un **Árbitro (`arbiterOnly: true`)** para lograr quórum impar sin duplicar costos de almacenamiento.
* **Mecánica del Oplog:** Comprobación práctica de cómo MongoDB transforma operaciones relativas (`$inc`) en registros absolutos **idempotentes** dentro de `local.oplog.rs`.
* **Resiliencia y el Dilema PSA:** Ejecución de *Failover* automático ante caídas abruptas (`kill -9`) y demostración práctica del bloqueo de `w: "majority"` cuando cae el nodo secundario en una arquitectura PSA.

> **Siguiente paso para tu Proyecto (Entregable 3):** Lleva exactamente estos tres archivos `/etc/mongod.conf` y la tabla de `/etc/hosts` a tus 3 máquinas virtuales Linux (usando sus IPs reales de red interna o Host-Only y el puerto `27017` en cada una).