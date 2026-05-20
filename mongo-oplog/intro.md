# Laboratorio Avanzado: Recuperación, Oplog y Rollbacks

Bienvenidos, Arquitectos de Datos de EcoRutas Logistics.

En este laboratorio no solo configuraremos un clúster; vamos a inspeccionar las entrañas del motor de MongoDB. Analizaremos cómo se propagan los datos a bajo nivel y simularemos un escenario catastrófico de partición de red para observar cómo el sistema descarta datos huérfanos para auto-sanarse.

### ¿Qué haremos?

Desplegaremos un clúster de 3 nodos (Primario, Secundario y un Árbitro).

Inspeccionaremos la colección local.oplog.rs para entender la idempotencia.

Forzaremos un escenario de "Split-Brain" (Cerebro Dividido) jugando con la red de Docker.

Recuperaremos los datos de telemetría descartados inspeccionando la carpeta rollback/ a nivel del sistema operativo.

Cuando estés listo para explorar el motor de bases de datos, avanza al primer paso.