# Operaciones Críticas en MongoDB

¡Bienvenido al laboratorio práctico! Como futuro Arquitecto de Datos o DBA, no solo debes saber cómo guardar información, sino cómo protegerla cuando las cosas salen mal.

En los próximos minutos, utilizaremos un entorno *Ubuntu Linux* con *MongoDB 7.0* preconfigurado como un Replica Set de nodo único (requisito indispensable para la alta disponibilidad y las transacciones).

### Objetivos del Taller

1\. Generar carga masiva de datos en estado natural (Auto-commit).

2\. Auditar el rendimiento de las consultas y optimizarlas usando el Database Profiler.

3\. Ejecutar un bloque de código aislando operaciones bajo una Transacción ACID (MVCC), forzando un error para validar el Rollback.

La terminal a tu derecha está inicializando el motor en este momento. Cuando veas el mensaje verde de confirmación, presiona Start.