## Paso 3: Análisis Forense de Metadatos

El NameNode sabe la verdad. Él tiene el mapa en su memoria RAM que dicta exactamente cómo está cortado nuestro `dataset.csv`. 

Para acceder a esos metadatos profundos, Hadoop nos ofrece el comando **FSCK** (File System Check). Este comando interroga directamente al NameNode sobre la anatomía física de un archivo.

Ejecútalo:

`hdfs fsck /input_data/dataset.csv -files -blocks -locations`{{execute}}

### Análisis del Resultado (El Momento ¡Ajá!)

Busca las siguientes líneas clave en el reporte que acaba de salir:

1.  **`Total blocks (validated): 2`**
    ¡La matemática es exacta! Como los 160 MB superan el límite de 128 MB, el NameNode confirma que el archivo fue fragmentado físicamente en dos pedazos.
2.  **`0. BP-... len=134217728`**
    Este es el **Bloque A**. Fíjate en el `len` (length). ¡Es exactamente 134,217,728 bytes (128 Megabytes perfectos)! HDFS cortó sin piedad exactamente en ese byte.
3.  **`1. BP-... len=...`**
    Este es el **Bloque B**. Es el remanente de megabytes que componen el resto del archivo.
4.  **`repl=1`**
    Indica que el factor de replicación es 1. (Recuerda: por defecto en producción es 3, pero como aquí simulamos todo en un solo servidor para el laboratorio, Hadoop inteligentemente baja la replicación a 1).

### La Ilusión de la Lectura

HDFS tiene dos bloques físicos regados en el clúster, pero para el usuario (o para el motor de procesamiento), el archivo debe lucir como uno solo. 

Vamos a leer el archivo directamente desde HDFS. 
*(Nota: Usaremos el comando `head` de Linux al final para mostrar solo las primeras 20 líneas, ya que imprimir 160MB de texto saturaría tu navegador).*

`hdfs dfs -cat /input_data/dataset.csv | head -n 20`{{execute}}

**¡Y ahí lo tienes!** Transacciones bancarias reales siendo leídas. Por debajo, HDFS unió los metadatos y comenzó a enviarte el flujo de texto (streaming) desde los DataNodes de forma tan transparente que tu sistema operativo pensó que estaba leyendo un archivo continuo tradicional.