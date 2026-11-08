# Paso 1: Preparación del Sistema, SSH e Instalación Base de Hadoop

Apache Hadoop está escrito en Java y utiliza el protocolo **SSH (Secure Shell)** para que el nodo maestro (`NameNode` / `ResourceManager`) pueda enviar órdenes de encendido, apagado y monitoreo a los nodos trabajadores (`DataNodes` / `NodeManagers`). 

Incluso en una configuración **Pseudo-Distribuida** (donde un solo servidor cumple ambos roles sobre `localhost`), Hadoop necesita conectarse a sí mismo vía SSH sin solicitar contraseña interactiva.

---

### 1.1 Verificar Java y los archivos en el servidor

Para ahorrarte el tiempo de descarga por red de más de 600 MB, el instalador oficial de Hadoop (`hadoop-3.3.6.tar.gz`) y el archivo crudo de registros (`raw_pos_transactions.log`) ya se encuentran en tu directorio `/root`. 

Verifica la versión de Java instalada y lista los archivos disponibles:

```bash
java -version && ls -lh /root
```{{exec}}

---

### 1.2 Configurar SSH sin contraseña (Passwordless SSH)

Primero, asegúrate de que el servicio SSH esté activo y genera un par de llaves criptográficas RSA nuevas y sin frase de paso para el usuario `root` (eliminando antes cualquier llave residual de la imagen base):

```bash
service ssh start
rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
```{{exec}}

Ahora, autoriza tu llave pública agregándola al archivo `~/.ssh/authorized_keys` y aplica los permisos estrictos (`700` para el directorio y `600` para el archivo) que exige el protocolo SSH:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```{{exec}}

Comprueba que puedes conectarte a `localhost` sin que el sistema te pida contraseña (el parámetro `-o StrictHostKeyChecking=no` registra automáticamente la huella del host en el primer intento):

```bash
ssh -o StrictHostKeyChecking=no localhost "echo 'Conexión SSH local exitosa en:' $(hostname)"
```{{exec}}

---

### 1.3 Desempaquetar e instalar los binarios de Hadoop

El estándar en sistemas Linux es alojar el software de terceros en el directorio `/opt`. Descomprime el archivo `hadoop-3.3.6.tar.gz` dentro de `/opt` y crea un enlace simbólico o renómbralo a `/opt/hadoop` para facilitar su administración:

```bash
tar -xzf /root/hadoop-3.3.6.tar.gz -C /opt/
mv /opt/hadoop-3.3.6 /opt/hadoop
ls -la /opt/hadoop
```{{exec}}

Observa las carpetas principales dentro de `/opt/hadoop`:
* `bin/`: Comandos de usuario como `hadoop` y `hdfs`.
* `sbin/`: Scripts de administración para levantar demonios (`start-dfs.sh`, `start-yarn.sh`).
* `etc/hadoop/`: Archivos XML de configuración del clúster.
* `share/hadoop/`: Librerías `.jar` del ecosistema (incluyendo *Hadoop Streaming*).

---

### 1.4 Configurar las Variables de Entorno

Para ejecutar comandos de Hadoop desde cualquier ruta y permitir que sus demonios se ejecuten con el usuario `root` en este entorno de laboratorio, agregaremos las variables de entorno al perfil `~/.bashrc` y las cargaremos en la sesión actual:

```bash
cat << 'EOF' >> ~/.bashrc

# === Variables de Entorno de Apache Hadoop ===
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# Permisos de ejecución de demonios para entorno de laboratorio
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
EOF

source ~/.bashrc
```{{exec}}

Verifica que el binario de Hadoop ya responde correctamente en la terminal:

```bash
hadoop version
```{{exec}}