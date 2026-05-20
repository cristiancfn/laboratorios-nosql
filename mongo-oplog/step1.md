### Fase 1: Despliegue de la Topología

Iniciaremos creando nuestro entorno distribuido. Haz clic en el siguiente bloque para crear el archivo docker-compose.yml. Mapearemos los volúmenes de datos directamente a nuestro entorno Linux para poder inspeccionarlos más adelante.

```bash
cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  ecorutas-nodo1:
    image: mongo:6.0
    container_name: ecorutas-nodo1
    command: ["--replSet", "ecorutas-rs", "--bind_ip_all", "--port", "27017"]
    ports:
      - "27017:27017"
    volumes:
      - "./data/nodo1:/data/db"
    networks:
      - ecorutas-net
    
  ecorutas-nodo2:
    image: mongo:6.0
    container_name: ecorutas-nodo2
    command: ["--replSet", "ecorutas-rs", "--bind_ip_all", "--port", "27018"]
    ports:
      - "27018:27018"
    volumes:
      - "./data/nodo2:/data/db"
    networks:
      - ecorutas-net

  ecorutas-arbitro:
    image: mongo:6.0
    container_name: ecorutas-arbitro
    command: ["--replSet", "ecorutas-rs", "--bind_ip_all", "--port", "27019"]
    ports:
      - "27019:27019"
    volumes:
      - "./data/arbitro:/data/db"
    networks:
      - ecorutas-net

networks:
  ecorutas-net:
    driver: bridge
EOF
```{{execute}}

Levanta la infraestructura en segundo plano:

```bash
docker-compose up -d
```{{execute}}

Espera unos segundos y ejecuta el siguiente comando para inicializar el clúster (Replica Set). Le daremos prioridad al Nodo 1 para que sea nuestro Primario por defecto:

```bash
sleep 5 && docker exec -i ecorutas-nodo1 mongosh --port 27017 --eval 'rs.initiate({
  _id: "ecorutas-rs",
  members: [
    { _id: 0, host: "ecorutas-nodo1:27017", priority: 2 },
    { _id: 1, host: "ecorutas-nodo2:27018", priority: 1 },
    { _id: 2, host: "ecorutas-arbitro:27019", arbiterOnly: true }
  ]
})'
```{{execute}}

La infraestructura está lista.