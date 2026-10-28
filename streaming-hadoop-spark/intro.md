# Bienvenido al Laboratorio de Procesamiento de Datos en Movimiento (*Data in Motion*)

En los sistemas empresariales modernos —como detección de fraude transaccional, telemetría de motores o monitoreo clínico—, esperar al proceso **Batch nocturno de las 12:00 AM** es inaceptable. Necesitamos procesar los eventos a medida que ocurren.

En este laboratorio práctico, construirás y compararás dos arquitecturas para procesar un flujo continuo de logs de un servidor web que sufre desconexiones intermitentes:

1. **Fase 1 (Productor en Vivo):** Desplegarás un generador de tráfico HTTP que escribe logs cada 0.5 segundos e inyecta deliberadamente **Hechos de Llegada Tardía (*Late Arriving Facts*)** con atrasos de `-8s` y `-35s`.
2. **Fase 2 (Enfoque Hadoop Streaming / Unix Pipes):** Procesarás el flujo usando un pipeline `Mapper -> Reducer` sobre `stdin/stdout`, observando qué ocurre con la memoria RAM cuando agrupamos por *Event Time* sin un mecanismo de expiración de estado.
3. **Fase 3 (Enfoque Stateful con PySpark Structured Streaming):** Implementarás **Tumbling Windows** de 10 segundos con **Watermarking** de 15 segundos para absorber rezagados válidos y descartar eventos obsoletos protegiendo la memoria del clúster.

---
> **Nota importante:** Espera a que la terminal de la derecha muestre el mensaje `✅ ¡Entorno listo!` antes de avanzar al primer paso.