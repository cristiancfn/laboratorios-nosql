# ¡Laboratorio Completado!

Excelente trabajo. Has diseñado, auditado, destruido y recuperado un clúster distribuido de MongoDB operando directamente sobre procesos nativos de Linux, tal como lo hace un Arquitecto de Datos Senior en entornos críticos.

### Resumen de competencias adquiridas:

1. **Despliegue de Replica Sets Nativos:** Configuraste una arquitectura de 3 nodos (**Primario**, **Secundario** y **Árbitro**) gestionando prioridades electorales sin depender de contenedores.
2. **Auditoría del Oplog (`local.oplog.rs`):** Comprobaste que la replicación se basa en registros de estado idempotentes con marcas de tiempo y términos de mandato.
3. **Alta Disponibilidad vs. Backup Lógico (`mongodump` / `mongorestore`):** Demostraste que un error humano (`dropDatabase()`) se propaga instantáneamente por el Oplog a todas las réplicas, por lo que las copias de respaldo externas en formato BSON son indispensables.
4. **Resolución de Split-Brain y Forense de Rollbacks (`bsondump`):** Forzaste una divergencia de líneas temporales entre nodos, verificaste cómo el motor ejecuta un *Rollback* automático para preservar la consistencia del clúster y rescataste los documentos huérfanos desde el directorio `/datos/nodo1/rollback/`.

Ya puedes cerrar esta pestaña.