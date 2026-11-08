# Paso 2: Configuración Pseudo-Distribuida y Tuning de Memoria

Por defecto, una instalación limpia de Hadoop viene configurada en modo **Standalone (Local)**: no levanta demonios ni usa HDFS, sino que lee del disco local en un único proceso Java.

Para transformarlo en un clúster **Pseudo-Distribuido**, debemos editar cinco archivos clave ubicados en `/opt/hadoop/etc/hadoop/`.

---

### 2.1 Tuning de Memoria JVM en `hadoop-env.sh` (Crítico en contenedores)

En un entorno con memoria RAM limitada (entre 2 GB y 4 GB), levantar 5 demonios de infraestructura (`NameNode`, `DataNode`, `SecondaryNameNode`, `ResourceManager`, `NodeManager`) más los contenedores de ejecución de MapReduce con la configuración por defecto (1 GB por proceso) agotará la memoria RAM y provocará que el kernel de Linux cierre procesos forzosamente (*OOM Killer*).

Configuraremos en `hadoop-env.sh` la ruta explícita de `JAVA_HOME`, definiremos que SSH no bloquee por confirmación de huella y limitaremos el *Heap Size* máximo de cada demonio a **512 MB**:

```bash
cat << 'EOF' >> /opt/hadoop/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_SSH_OPTS="-o StrictHostKeyChecking=no"
export HADOOP_HEAPSIZE_MAX=512m
export HADOOP_HEAPSIZE_MIN=256m
EOF
```{{exec}}

---

### 2.2 Configurar `core-site.xml` (El Punto de Entrada al Clúster)

Este archivo define las propiedades globales del núcleo de Hadoop. La propiedad `fs.defaultFS` indica a todos los clientes y herramientas cuál es el sistema de archivos por defecto y en qué dirección y puerto escucha el `NameNode` (`hdfs://localhost:9000`):

```bash
cat << 'EOF' > /opt/hadoop/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        <description>URI del NameNode principal de HDFS</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/hadoop/data/tmp</value>
        <description>Directorio base temporal para procesos de Hadoop</description>
    </property>
</configuration>
EOF
```{{exec}}

---

### 2.3 Configurar `hdfs-site.xml` (Comportamiento del Almacenamiento HDFS)

En un clúster real de producción, el factor de replicación por defecto (`dfs.replication`) es `3` (cada bloque de 128 MB se copia en 3 servidores distintos). Como aquí contamos con un único nodo (`DataNode`), debemos fijar `dfs.replication` en `1` para evitar advertencias de bloques sub-replicados. También definiremos las rutas físicas en el sistema operativo donde el `NameNode` guardará los metadatos (*fsimage* y *edit logs*) y el `DataNode` guardará los bloques de datos:

```bash
mkdir -p /opt/hadoop/data/namenode
mkdir -p /opt/hadoop/data/datanode
mkdir -p /opt/hadoop/data/tmp

cat << 'EOF' > /opt/hadoop/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Factor de replicacion ajustado a 1 para modo uninodo</description>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///opt/hadoop/data/namenode</value>
        <description>Ruta local donde el NameNode almacena la tabla de metadatos</description>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///opt/hadoop/data/datanode</value>
        <description>Ruta local donde el DataNode almacena los bloques fisicos</description>
    </property>
</configuration>
EOF
```{{exec}}

---

### 2.4 Configurar `mapred-site.xml` y `yarn-site.xml` (Cómputo y Recursos)

* **`mapred-site.xml`:** Indica que los trabajos MapReduce se ejecutarán gestionados sobre el orquestador **YARN** y ajusta el límite de memoria RAM de cada contenedor `Map`, `Reduce` y `ApplicationMaster` a 512 MB.
* **`yarn-site.xml`:** Habilita el servicio auxiliar `mapreduce_shuffle` (indispensable para transferir y ordenar las llaves entre los Mappers y los Reducers) y desactiva el chequeo estricto de memoria virtual (`yarn.nodemanager.vmem-check-enabled=false`) para evitar cierres prematuros en contenedores Linux.

Ejecuta el siguiente bloque para aplicar ambas configuraciones:

```bash
cat << 'EOF' > /opt/hadoop/etc/hadoop/mapred-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.resource.mb</name>
        <value>512</value>
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>256</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>256</value>
    </property>
    <property>
        <name>mapreduce.app-submission.cross-platform</name>
        <value>true</value>
    </property>
</configuration>
EOF

cat << 'EOF' > /opt/hadoop/etc/hadoop/yarn-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>1536</value>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>256</value>
    </property>
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>
</configuration>
EOF
```{{exec}}

---

### 2.5 Formatear el NameNode y Arrancar el Clúster

Antes de usar HDFS por primera vez, es obligatorio **formatear el NameNode**. Este comando inicializa la estructura de metadatos (`fsimage`) en `/opt/hadoop/data/namenode`:

```bash
hdfs namenode -format -nonInteractive
```{{exec}}

Ahora, inicia los demonios de almacenamiento (**HDFS**) y luego los demonios de procesamiento (**YARN**):

```bash
start-dfs.sh
start-yarn.sh
```{{exec}}

Verifica con la herramienta `jps` (Java Virtual Machine Process Status Tool) que los **5 demonios** estén corriendo en memoria:

```bash
jps
```{{exec}}

Deberías ver listados: `NameNode`, `DataNode`, `SecondaryNameNode`, `ResourceManager` y `NodeManager`.

> **Explora la Interfaz Gráfica de HDFS:** Haz clic en el siguiente enlace para abrir la consola web oficial del **NameNode** en una nueva pestaña del navegador:
> [Abrir Interfaz Web de HDFS NameNode (Puerto 9870)]({{TRAFFIC_HOST1_9870}})