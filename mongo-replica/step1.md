### Fase 1: Preparación de la Infraestructura

Vamos a crear nuestra infraestructura base. Haz clic en el siguiente bloque para generar automáticamente el archivo `docker-compose.yml` en tu máquina virtual:

```bash
cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  mongo-nodo-1:
    image: mongo:7.0
    container_name: nodo-primario
    command: ["--replSet", "mi_cluster", "--bind_ip_all"]
    ports:
      - "27017:27017"

  mongo-nodo-2:
    image: mongo:7.0
    container_name: nodo-secundario-1
    command: ["--replSet", "mi_cluster", "--bind_ip_all"]
    ports:
      - "27018:27017"

  mongo-nodo-3:
    image: mongo:7.0
    container_name: nodo-secundario-2
    command: ["--replSet", "mi_cluster", "--bind_ip_all"]
    ports:
      - "27019:27017"
EOF
```{{execute}}

Ahora, levanta los tres contenedores en segundo plano haciendo clic aquí:

```bash
docker compose up -d
```{{execute}}

Verifica que los tres contenedores estén corriendo correctamente:

```bash
docker ps
```{{execute}}