# Paso 3: Ejecutar la simulación

Nuestra infraestructura y nuestro código están listos. Es hora de desplegar el contenedor y observar cómo los datos "hablan por sí solos".

Levantemos el entorno analítico con Docker Compose:

```bash
docker-compose up
```{{execute}}

*La primera vez tomará un momento mientras descarga la imagen de Python e instala Scikit-Learn.*

*(Nota: Si ves una excepción de Python en la terminal de Docker Compose al final de la ejecución, es un detalle de la herramienta en este sistema, pero el proceso habrá finalizado correctamente si ves "miner_app exited with code 0").*

### Analizando los resultados

Una vez finalice la ejecución, la terminal te mostrará los 3 centroides que K-Means encontró de forma autónoma y se habrá generado el archivo `clusters_output.png`.

Para visualizar este artefacto analítico, levantaremos un servidor web ligero en el puerto 8080:

```bash
python3 -m http.server 8080
```{{execute}}

**Para ver la gráfica:**
1. En la parte superior de la interfaz de Killercoda, busca el botón **Ports** (Puertos).
2. Escribe **8080** y ábrelo (o haz clic si ya aparece listado).
3. Se abrirá una nueva pestaña en tu navegador con un índice de archivos. 
4. Haz clic sobre **`clusters_output.png`** para visualizar la segmentación de clientes.

En un entorno real, este tipo de artefactos o etiquetas de segmento viajarían de regreso a un Dashboard operativo.