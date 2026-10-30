# Laboratorio Práctico: Despliegue de un Replica Set PSA en Linux y Prueba de Failover

Bienvenidos. En esta sesión práctica dejaremos atrás el nodo *Standalone* (Punto Único de Fallo - SPOF) para construir una arquitectura de **Alta Disponibilidad** directamente sobre el sistema operativo Linux.

### Nota de Arquitectura e Infraestructura
En un entorno de producción (o en su **Entregable 3** con 3 máquinas virtuales independientes), cada nodo reside en un servidor separado comunicándose por el puerto `27017`. Para optimizar los recursos de hardware hoy, ejecutaremos **3 procesos independientes de `mongod`** dentro de este mismo servidor Linux utilizando los puertos `27017`, `27018` y `27019`. La lógica de red TCP/IP, archivos de configuración YAML y protocolo de consenso de MongoDB son **exactamente iguales**.

### ¿Qué haremos en este laboratorio?
1. **Configuración en Linux:** Mapear nombres de host en `/etc/hosts`, preparar directorios de datos y redactar los archivos YAML de configuración (`/etc/mongod*.conf`) limitando la caché de WiredTiger.
2. **Inicialización del Clúster (Topología PSA):** Desplegar un nodo **P**rimario, un **S**ecundario y un **Á**rbitro, configurando prioridades de elección.
3. **Inspección del Oplog y del Árbitro:** Comprobar la replicación asíncrona, verificar que el Árbitro no almacena datos y evidenciar la **idempotencia** (`$inc` transformado en `$set`) dentro de `local.oplog.rs`.
4. **Failover y el Dilema PSA:** Simular la caída abrupta del Primario (`kill -9`) para medir el tiempo de elección, y demostrar en vivo la trampa del *Write Concern* `w: "majority"` cuando cae el nodo Secundario.

> **Importante:** Espera a que en la terminal de la derecha aparezca el mensaje `✅ ¡Entorno listo!` antes de avanzar a la Fase 1.