#!/bin/bash
# Este script corre en silencio mientras el estudiante lee la introducción.

# 1. Instalar dependencias esenciales
apt-get update
apt-get install -y openjdk-8-jdk ssh pdsh wget

# 2. Iniciar el servicio SSH y Configurar llaves sin contraseña (Requisito estricto)
service ssh start
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
echo "Host *" > ~/.ssh/config
echo "  StrictHostKeyChecking no" >> ~/.ssh/config
chmod 0600 ~/.ssh/config

# 3. Descargar Hadoop (Usamos la versión 3.3.6)
cd /opt
wget -q https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xzf hadoop-3.3.6.tar.gz
mv hadoop-3.3.6 /usr/local/hadoop

# 4. Inyectar Variables de Entorno (Incluyendo el bypass de seguridad para usuario Root)
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
echo 'export HDFS_NAMENODE_USER="root"' >> ~/.bashrc
echo 'export HDFS_DATANODE_USER="root"' >> ~/.bashrc
echo 'export HDFS_SECONDARYNAMENODE_USER="root"' >> ~/.bashrc
echo 'export YARN_RESOURCEMANAGER_USER="root"' >> ~/.bashrc
echo 'export YARN_NODEMANAGER_USER="root"' >> ~/.bashrc

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"

# 5. Configurar los XML de HDFS (core-site y hdfs-site)
cat <<EOF > /usr/local/hadoop/etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF

cat <<EOF > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///tmp/hadoop-namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///tmp/hadoop-datanode</value>
    </property>
</configuration>
EOF

# Asignar JAVA_HOME dentro de la config de Hadoop
sed -i 's/# export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
echo 'export PDSH_RCMD_TYPE=ssh' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# 6. Formatear el disco lógico e Iniciar el NameNode y DataNode
hdfs namenode -format -force
start-dfs.sh

# 7. Crear el archivo de prueba masivo (150 MB de datos aleatorios puros)
cd /root
# Extraemos 115MB de urandom y al pasarlo por base64 el archivo final pesará aprox 153MB de texto alfanumérico
head -c 115M /dev/urandom | base64 > /root/dataset.csv

# 8. Señal de finalización para el script foreground
echo "done" > /root/setup_done.txt