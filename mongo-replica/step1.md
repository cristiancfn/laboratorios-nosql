### Fase 1: Resolución de Nombres y Configuración de Demonios en Linux

#### Paso 1: Resolución de nombres en `/etc/hosts`
En lugar de quemar direcciones IP en la configuración del clúster, todo arquitecto de datos utiliza nombres de dominio locales. Vamos a mapear `nodo1`, `nodo2` y `arbitro` en el archivo `/etc/hosts` de Linux y verificar su resolución con `ping`:

```bash
cat << 'EOF' >> /etc/hosts
127.0.0.1 nodo1
127.0.0.1 nodo2
127.0.0.1 arbitro
EOF

ping -c 2 nodo1
```{{execute}}

*(Nota sobre Firewalls en VMs separadas: Cuando despliegues esto en 3 máquinas virtuales distintas para tu proyecto, recuerda abrir el puerto en el firewall de cada VM ejecutando `sudo ufw allow 27017/tcp` o `sudo firewall-cmd --add-port=27017/tcp --permanent`).*

---

#### Paso 2: Creación de directorios de datos (`dbPath`) y logs
Cada instancia de `mongod` requiere su propio directorio aislado para almacenar los archivos de WiredTiger y sus registros de eventos:

```bash
mkdir -p /var/lib/mongo1 /var/lib/mongo2 /var/lib/mongo_arb
mkdir -p /var/log/mongodb
```{{execute}}

---

#### Paso 3: Archivos de configuración YAML (`/etc/mongod*.conf`)
Crearemos los tres archivos de configuración equivalentes al `/etc/mongod.conf` estándar. Observa tres directivas críticas:
* `net.bindIp: 0.0.0.0`: Permite escuchar conexiones desde cualquier interfaz de red (no solo `localhost`).
* `wiredTiger.engineConfig.cacheSizeGB: 0.25`: Limita la RAM del motor de almacenamiento para evitar saturar el servidor.
* `replication.replSetName: "rsProyecto"`: Identifica a los tres nodos como miembros del mismo clúster.

Genera los tres archivos de configuración:

```bash
cat << 'EOF' > /etc/mongod1.conf
storage:
  dbPath: /var/lib/mongo1
  wiredTiger:
    engineConfig:
      cacheSizeGB: 0.25
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod1.log
net:
  port: 27017
  bindIp: 0.0.0.0
processManagement:
  fork: true
replication:
  replSetName: "rsProyecto"
EOF

cat << 'EOF' > /etc/mongod2.conf
storage:
  dbPath: /var/lib/mongo2
  wiredTiger:
    engineConfig:
      cacheSizeGB: 0.25
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod2.log
net:
  port: 27018
  bindIp: 0.0.0.0
processManagement:
  fork: true
replication:
  replSetName: "rsProyecto"
EOF

cat << 'EOF' > /etc/mongod_arb.conf
storage:
  dbPath: /var/lib/mongo_arb
  wiredTiger:
    engineConfig:
      cacheSizeGB: 0.25
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod_arb.log
net:
  port: 27019
  bindIp: 0.0.0.0
processManagement:
  fork: true
replication:
  replSetName: "rsProyecto"
EOF
```{{execute}}

---

#### Paso 4: Iniciar las instancias y verificar puertos en escucha
Arranquemos los 3 demonios `mongod` y comprobemos a nivel de sistema operativo que los puertos TCP `27017`, `27018` y `27019` están activos:

```bash
mongod --config /etc/mongod1.conf
mongod --config /etc/mongod2.conf
mongod --config /etc/mongod_arb.conf

ss -tulpn | grep mongod
```{{execute}}

Con los tres procesos corriendo en segundo plano (`fork: true`), estamos listos para ensamblar el Replica Set.