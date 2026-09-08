# Paso 3: Ejecutar la simulación

Nuestra infraestructura y nuestro código están listos. Es hora de desplegar el contenedor y observar cómo los datos "hablan por sí solos".

Levantemos el entorno analítico con Docker Compose:

```bash
docker-compose up
```{{execute}}

*La primera vez tomará un momento mientras descarga la imagen de Python e instala Scikit-Learn.*

### Analizando los resultados
Una vez finalice la ejecución, fíjate en dos cosas:
1. La terminal te mostró los 3 centroides que K-Means encontró de forma autónoma.
2. Comprueba que el artefacto visual se generó correctamente en tu directorio:

```bash
ls -l clusters_output.png
```{{execute}}

En un entorno real de tu Proyecto de Aula, este tipo de artefactos o etiquetas de segmento viajarían de regreso a un Dashboard operativo.