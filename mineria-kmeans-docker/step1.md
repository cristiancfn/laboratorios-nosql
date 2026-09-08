# Paso 1: Explorar la infraestructura (Docker Compose)

Como aprendimos en clase, es crucial aislar nuestros entornos analíticos. Vamos a crear nuestra infraestructura como código.

En tu terminal, vamos a crear el archivo de dependencias de Python y la receta de Docker Compose. Haz clic en los bloques de código abajo para que se ejecuten automáticamente en tu terminal.

### 1. Definir Dependencias
Creamos el archivo `requirements.txt`:

```bash
cat <<EOF> requirements.txt
pandas
scikit-learn
matplotlib
numpy
EOF
```{{execute}}

### 2. Configurar la Infraestructura
Creamos el archivo `docker-compose.yml`:

```bash
cat <<EOF> docker-compose.yml
version: '3.8'
services:
  data_miner:
    image: python:3.9-slim
    container_name: miner_app
    volumes:
      - .:/app
    working_dir: /app
    command: /bin/sh -c "pip install -r requirements.txt && python kmeans_lab.py"
EOF
```{{execute}}

Notarás en la configuración que estamos usando una imagen ligera de Python y mapeando nuestro volumen actual al directorio `/app` del contenedor.