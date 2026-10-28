# 🎯 ¡Laboratorio Completado con Éxito!

En esta práctica has experimentado de primera mano la transición desde el procesamiento por lotes hacia las **Arquitecturas de Streaming Modernas**:

1. **Datos en Movimiento (*Data in Motion*):** Comprobaste cómo desacoplar la generación continua de eventos (`producer.py`) de su consumo analítico.
2. **Limitaciones del Procesamiento Stateless / Sin Marca de Agua:** Viste cómo un pipeline clásico estilo Hadoop Streaming (`mapper.py` + `reducer.py`) acumula claves indefinidamente en memoria cuando intenta agrupar por *Event Time* sin saber cuándo expira una ventana.
3. **Semántica Temporal y Watermarking:** Implementaste **Tumbling Windows** de 10 segundos con un **Watermark** de 15 segundos en PySpark Structured Streaming, logrando absorber hechos tardíos (`-8s`) y descartar eventos fuera de umbral (`-35s`) para garantizar la estabilidad de la memoria RAM.

### Conexión con la Arquitectura Medallón (Lakehouse)
* **Capa Bronce:** Representada por los eventos crudos que aterrizan continuamente en `/tmp/stream_dir`.
* **Capa Plata:** Filtrado de códigos de error (`404` y `500`), tipado de esquemas y control de *Watermarking*.
* **Capa Oro:** Tablas agregadas por ventanas de tiempo listas para alimentar dashboards operacionales en tiempo real.