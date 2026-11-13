# Laboratorio de Benchmarking en Motores NoSQL

Evaluar una base de datos no consiste únicamente en lanzar millones de peticiones al azar, sino en seguir un método estructurado que permita descartar opciones inviables, comparar configuraciones frente a frente y medir los límites de escalabilidad del sistema.

En este laboratorio aplicarás las **tres etapas clásicas del proceso de Benchmarking** sobre un caso de uso de telemetría IoT y monitoreo de rutas:

1. **Etapa 1: Culling (Descarte):** Evaluaremos dos familias NoSQL vistas en el curso (**Clave-Valor con Redis** vs. **Documental con MongoDB**) frente a requerimientos funcionales de filtrado secundario y consultas por rangos.
2. **Etapa 2: Comparison (Comparación):** Una vez seleccionado el motor documental, pondremos a competir frente a frente distintas estrategias de ingesta (**Inserción Individual vs. Bulk Write**) y diseño de índices (**Claves con localidad secuencial vs. Claves aleatorias**) sobre una caché de **WiredTiger restringida a 256 MB**.
3. **Etapa 3: Scaling (Escalabilidad):** Someteremos al modelo ganador a un incremento progresivo de concurrencia (1, 4, 16 y 32 hilos simultáneos) para observar cómo evolucionan el *throughput* (QPS) y la latencia en los percentiles **p95 y p99** cuando los recursos de CPU se saturan.

> **Nota importante:** Espera a que en la terminal aparezca el mensaje `✅ ¡Entorno listo!` antes de comenzar el Paso 1.