# ¡Laboratorio Completado!

Has ejecutado un flujo completo de **Benchmarking de Bases de Datos NoSQL** adaptando las pruebas a un entorno con recursos acotados:

1. **Culling (Descarte):** Comprobaste empíricamente por qué una arquitectura Clave-Valor pura (Redis) se descarta temprano cuando el caso de uso exige consultas ad-hoc por múltiples atributos secundarios sin clave conocida, seleccionando MongoDB como candidato.
2. **Comparison (Comparación):** Mediste dentro de MongoDB el impacto dramático de usar operaciones *Bulk* frente a inserciones individuales, así como la penalización en tiempo y espacio de memoria RAM cuando se indexan claves aleatorias frente a claves secuenciales en árboles B-Tree.
3. **Scaling (Escalabilidad):** Identificaste el punto de saturación de CPU del servidor al escalar de 1 a 32 clientes concurrentes, observando cómo se aplana la curva de *Throughput (QPS)* mientras se dispara la latencia en el percentil 99 (*p99*).