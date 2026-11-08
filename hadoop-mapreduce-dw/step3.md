# Paso 3: Arquitectura del Data Lake e Ingesta en HDFS

Con el clúster arriba, el siguiente paso es organizar el sistema de archivos distribuido (**HDFS**) siguiendo las buenas prácticas de un **Data Lake** que alimenta a una Bodega de Datos.

Crearemos dos zonas claramente diferenciadas en HDFS:
* **`/datalake/raw/pos_logs` (Zona Cruda / Landing Zone):** Donde aterrizan los archivos originales sin ninguna alteración, preservando la historia tal cual fue emitida por el sistema transaccional.
* **`/datalake/refined/` (Zona Refinada / Staging para el Data Warehouse):** Donde el proceso MapReduce depositará los datos limpios y pre-agregados.

---

### 3.1 Explorar el archivo de Logs Crudos en el sistema local

Antes de subir el archivo a HDFS, inspeccionemos en el sistema operativo local cómo luce `/root/raw_pos_transactions.log`.

Cada línea válida tiene **8 campos separados por el carácter tubería (`|`)**:
`FECHA_HORA | ID_TIENDA | ID_PRODUCTO | CATEGORIA | CANTIDAD | MONTO_TOTAL | METODO_PAGO | ESTADO`

Ejecuta el siguiente comando para contar cuántas líneas tiene el archivo y observar las primeras 15 filas:

```bash
wc -l /root/raw_pos_transactions.log && head -n 15 /root/raw_pos_transactions.log
```{{exec}}

Observa si hay anomalías en el archivo ejecutando una búsqueda de líneas corruptas o estados cancelados:

```bash
grep -E "CORRUPTED|CANCELLED|ERROR" /root/raw_pos_transactions.log | head -n 10
```{{exec}}

Notarás tres problemas clásicos de calidad de datos que jamás deberían entrar directo a una Tabla de Hechos:
1. Líneas truncadas o dañadas (`CORRUPTED_LINE|...`).
2. Transacciones que no se concretaron (`CANCELLED` o `ERROR_TIMEOUT`).
3. Inconsistencia en mayúsculas/minúsculas en el método de pago (ej. `efectivo` vs `EFECTIVO`).

---

### 3.2 Crear la estructura de directorios en HDFS e ingestar el archivo

Utiliza el comando `hdfs dfs -mkdir -p` para crear la jerarquía del Data Lake dentro de HDFS:

```bash
hdfs dfs -mkdir -p /datalake/raw/pos_logs
hdfs dfs -mkdir -p /datalake/refined
```{{exec}}

Ahora, transfiere el archivo desde el disco local de Linux (`/root/raw_pos_transactions.log`) hacia el almacenamiento distribuido de HDFS usando la instrucción `-put`:

```bash
hdfs dfs -put /root/raw_pos_transactions.log /datalake/raw/pos_logs/
```{{exec}}

Verifica que el archivo ya vive en HDFS consultando el listado del directorio:

```bash
hdfs dfs -ls -h /datalake/raw/pos_logs/
```{{exec}}

---

### 3.3 Inspeccionar los Bloques Físicos y Metadatos en HDFS

Cuando subes un archivo a HDFS, el `NameNode` registra la ruta en su árbol de metadatos y el archivo se divide en bloques físicos (por defecto de 128 MB) almacenados dentro del `DataNode`.

Ejecuta la herramienta de auditoría `hdfs fsck` (*File System Check*) para ver en cuántos bloques se almacenó nuestro archivo y en qué nodo reside:

```bash
hdfs fsck /datalake/raw/pos_logs/raw_pos_transactions.log -files -blocks -locations
```{{exec}}

Incluso puedes comprobar en qué carpeta física del sistema operativo Linux el `DataNode` guardó el bloque binario (`blk_...`) y su archivo de suma de verificación (`.meta`):

```bash
find /opt/hadoop/data/datanode/ -name "blk_*"
```{{exec}}

> **Tip visual:** Si vuelves a la pestaña de la [Interfaz Web del NameNode (Puerto 9870)]({{TRAFFIC_HOST1_9870}}) y entras en el menú superior **Utilities -> Browse the file system**, podrás navegar gráficamente por `/datalake/raw/pos_logs/` y ver el archivo cargado.