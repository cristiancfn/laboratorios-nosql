# Paso 3: Ejecutar la simulación

Nuestra infraestructura y nuestro código están listos. Es hora de desplegar el contenedor y observar cómo los datos "hablan por sí solos".

Levantemos el entorno analítico con Docker Compose:

```bash
docker-compose up
```{{execute}}

*La primera vez tomará un momento mientras descarga la imagen de Python e instala Scikit-Learn.*

*(Nota: Si ves una excepción de Python en la terminal de Docker Compose al final de la ejecución, ignórala. Es un bug conocido de la herramienta en este sistema operativo, el proceso habrá finalizado correctamente si ves "miner_app exited with code 0").*

### Analizando los resultados

Una vez finalice la ejecución, la terminal te mostrará los 3 centroides que K-Means encontró de forma autónoma y se habrá generado el archivo `clusters_output.png`.

Para visualizar este artefacto analítico, descárgalo desde el editor:

1. Ve al explorador de archivos en el panel izquierdo.
2. Haz clic derecho sobre el archivo **`clusters_output.png`**.
3. Selecciona la opción **Download** (Descargar).
4. Abre el archivo en tu computadora para ver la gráfica de segmentación.

En un entorno real de tu Proyecto de Aula, este tipo de artefactos o etiquetas de segmento viajarían de regreso a un Dashboard operativo.