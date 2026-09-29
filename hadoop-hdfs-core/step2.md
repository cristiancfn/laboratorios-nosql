## Paso 2: Ingesta y el Bloque de 128MB

Es hora de comprobar la teoría de la fragmentación física. 
Para este laboratorio, he generado automáticamente un archivo llamado `dataset.csv` en tu carpeta local. 

Primero, verifiquemos el tamaño físico de este archivo usando los comandos nativos de Linux:

`ls -lh /root/dataset.csv`{{execute}}

Verás que el archivo pesa **150 Megabytes**. 
Recuerda la teoría: El bloque estándar de Hadoop es de **128 MB**. Por lo tanto, al ingerir este archivo, HDFS estará matemáticamente obligado a cortarlo en dos pedazos.

### El Pipeline de Escritura en Acción

Vamos a actuar como el **Cliente HDFS** e inyectar este archivo en el clúster. 
Ejecuta el comando `put` para copiar el archivo de tu disco local (Linux) al disco distribuido (HDFS):

`hdfs dfs -put /root/dataset.csv /input_data/`{{execute}}

*¿Qué acaba de ocurrir invisiblemente?*
1. Tu terminal se comunicó con el **NameNode** para pedir permisos y rutas.
2. El cliente cortó el archivo a los 128 MB en la memoria.
3. El cliente envió los datos directamente al **DataNode**.

Verifiquemos que el archivo ya viva dentro de HDFS:

`hdfs dfs -ls -h /input_data`{{execute}}

HDFS te reportará orgullosamente que ahí está tu archivo de 150 MB. **La ilusión óptica de HDFS ha funcionado:** Te muestra el archivo completo, como si estuviera en una sola pieza.

Pero tú eres ingeniero de datos, y sabes que esa no es la verdad física. Vamos a desmentirlo en el siguiente paso.