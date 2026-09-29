# Laboratorio Práctico: Hadoop Distributed File System (HDFS)

Bienvenido a la sesión práctica de **Arquitectura Core de Big Data**.

A lo largo de la explicación teórica, analizamos cómo Hadoop resuelve el problema de la saturación I/O mediante hardware distribuido (DataNodes) y la fragmentación matemática estricta a 128 MB.

En este laboratorio, pasaremos de la abstracción a la realidad física. 

### ¿Qué vas a lograr en los próximos minutos?
1. Validar la existencia de los daemons maestros y esclavos mediante comandos de Java (JPS).
2. Crear un directorio en el sistema distribuido.
3. Subir un archivo de 150 Megabytes y ver cómo HDFS reacciona físicamente a este volumen.
4. Auditar los metadatos y comprobar con tus propios ojos la teoría del bloque de 128 MB.

Para eludir las limitaciones físicas de RAM, este entorno Killercoda se ha configurado automáticamente en **Modo Pseudo-Distribuido**. Esto significa que el NameNode (Maestro) y el DataNode (Esclavo) están corriendo como procesos independientes dentro de esta misma máquina, simulando un clúster real.

¡Comencemos!