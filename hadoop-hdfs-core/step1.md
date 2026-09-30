## Paso 1: El Ecosistema Vivo (JPS)

Antes de interactuar con HDFS, debemos asegurarnos de que la arquitectura Maestro-Esclavo que vimos en el tablero está realmente ejecutándose.

Dado que Hadoop está escrito íntegramente en Java, cada "Nodo" (NameNode, DataNode) es en realidad un proceso de la JVM (Java Virtual Machine) corriendo en segundo plano.

Ejecuta el siguiente comando (Java Virtual Machine Process Status Tool) para listar los procesos activos:

`jps`{{execute}}

**¿Qué deberías ver?**
Aparte del proceso `Jps` mismo, deberías ver obligatoriamente:
*   `NameNode`: El maestro de metadatos (el controlador aéreo).
*   `DataNode`: El esclavo de almacenamiento físico.
*   `SecondaryNameNode`: El asistente que fusiona el EditLog y el FsImage.

*Nota de Arquitectura:* En un clúster de producción real (ej. 100 servidores), si corres `jps` en el servidor principal, solo verías el `NameNode`. Si entras por SSH a uno de los 99 servidores esclavos y corres `jps`, solo verías el `DataNode`.

### Creando nuestro primer directorio distribuido

Ahora vamos a interactuar con el sistema de archivos. A diferencia del comando `mkdir` normal de Linux, debemos decirle al cliente de Hadoop que ejecute la orden en el clúster. 

Crea una carpeta llamada `/input_data` en HDFS:

`hdfs dfs -mkdir /input_data`{{execute}}

Y ahora verifiquemos que se haya creado correctamente:

`hdfs dfs -ls /`{{execute}}

Notarás que el directorio existe en HDFS, pero si ejecutas un `ls -l` normal de Linux en tu terminal, la carpeta no está ahí. HDFS es un sistema de archivos virtual montado por encima del sistema físico.