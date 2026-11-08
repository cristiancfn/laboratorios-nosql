# De HDFS a la Bodega de Datos: Instalación de Hadoop y Procesamiento con MapReduce

En las arquitecturas modernas de datos, los sistemas transaccionales y dispositivos generan grandes volúmenes de archivos de registro (*logs*) semiestructurados o sin estructura. Intentar cargar estos archivos crudos directamente en una **Bodega de Datos (Data Warehouse)** relacional suele ser ineficiente y costoso debido al ruido, registros corruptos y la altísima granularidad de los eventos.

Ahí es donde entran en juego **Apache Hadoop (HDFS)** y el paradigma **MapReduce** como capa de almacenamiento distribuido (*Data Lake / Staging*) y motor de procesamiento por lotes (*Batch Processing*).

---

## Arquitectura del Laboratorio

En este escenario construirás desde cero el primer eslabón de un pipeline analítico:

1. **Infraestructura Base (Modo Pseudo-Distribuido):** Instalarás y configurarás **Apache Hadoop 3.3.6** en un único servidor Ubuntu, donde cada componente del clúster (`NameNode`, `DataNode`, `ResourceManager`, `NodeManager`) se ejecutará como un proceso independiente de la Máquina Virtual de Java (JVM).
2. **Almacenamiento Distribuido (HDFS):** Estructurarás las zonas de un *Data Lake* (`/datalake/raw` y `/datalake/refined`) e ingestarás un archivo crudo con **50,000 eventos de punto de venta (`raw_pos_transactions.log`)**.
3. **Transformación Distribuida (MapReduce con Python):** Desarrollarás un proceso `Mapper` y `Reducer` mediante **Hadoop Streaming** que limpiará registros corruptos, filtrará transacciones efectivas, normalizará textos y calculará agregaciones diarias.
4. **Puente hacia el Modelo Dimensional:** Consolidarás los bloques procesados en HDFS para exportar la tabla de hechos pre-agregada **`fact_ventas_diarias.csv`**, lista para ser importada en un esquema en estrella (*Star Schema*) junto a sus dimensiones (`dim_fecha`, `dim_tienda`, `dim_producto`, `dim_metodo_pago`).

¡Espera a que la terminal indique **"¡Servidor listo!"** y haz clic en **Start** para comenzar!