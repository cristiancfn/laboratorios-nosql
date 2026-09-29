## Paso 3: Análisis Forense de Metadatos

El NameNode sabe la verdad. Él tiene el mapa en su memoria RAM que dicta exactamente cómo está cortado ese archivo. 

Para acceder a esos metadatos profundos, Hadoop nos ofrece un comando de auditoría llamado **FSCK** (File System Check). Este comando interroga directamente al NameNode sobre la anatomía de un archivo.

Ejecuta el siguiente comando para destripar nuestro archivo:

`hdfs fsck /input_data/dataset.csv -files -blocks -locations`{{execute}}

### Análisis del Resultado

Tómate un momento para leer la salida que arrojó la terminal. Busca las siguientes líneas clave:

1.  **`Total blocks (validated): 2`**
    ¡La matemática es exacta! Como 150 MB supera el límite de 128 MB, el NameNode nos confirma que el archivo fue fragmentado físicamente en dos bloques.
2.  **`0. BP-... len=134217728`**
    Este es el **Bloque A**. Fíjate en el `len` (length). ¡Es exactamente 134,217,728 bytes (128 Megabytes perfectos)! HDFS cortó sin piedad exactamente en ese byte.
3.  **`1. BP-... len=23068672`**
    Este es el **Bloque B**. Es el remanente (aprox. 22 MB) que compone el resto del archivo.
4.  **`repl=1`**
    Indica que el factor de replicación es 1. (Recuerda: por defecto en producción es 3, pero como aquí simulamos todo en un solo servidor para el laboratorio, Hadoop inteligentemente baja la replicación a 1).

### ¡Has comprobado la teoría!
Acabas de validar empíricamente que HDFS no es una base de datos ni guarda archivos como tu computadora personal. Es un motor matemático diseñado para descuartizar información en bloques de 128 MB, orquestar esos pedazos en un ejército de DataNodes, y luego presentarte la ilusión de que tu información sigue siendo un archivo continuo.