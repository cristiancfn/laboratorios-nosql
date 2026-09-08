# Paso 2: El algoritmo de Minería (K-Means)

Con la infraestructura definida, vamos a inyectar el código de Python que simulará nuestra extracción de la bodega de datos y el entrenamiento del algoritmo.

Haz clic en el bloque para crear el script `kmeans_lab.py`:

```bash
cat << 'EOF' > kmeans_lab.py
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

print("Generando datos simulados de clientes...")
np.random.seed(42)
X = np.concatenate([
    np.random.normal(loc=[25, 80], scale=5, size=(100, 2)),
    np.random.normal(loc=[55, 30], scale=5, size=(100, 2)),
    np.random.normal(loc=[35, 50], scale=5, size=(100, 2))
])

df = pd.DataFrame(X, columns=['Edad', 'Score_Gasto'])

print("Entrenando algoritmo K-Means con K=3...")
kmeans = KMeans(n_clusters=3, random_state=42)
df['Cluster'] = kmeans.fit_predict(df[['Edad', 'Score_Gasto']])

print("\nCentroides de los Clústeres:")
print(pd.DataFrame(kmeans.cluster_centers_, columns=['Edad', 'Score']))

plt.scatter(df['Edad'], df['Score_Gasto'], c=df['Cluster'], cmap='viridis')
plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1], s=300, c='red', marker='X')
plt.title('Segmentacion de Clientes - K-Means')
plt.savefig('clusters_output.png')
print("Grafico guardado como 'clusters_output.png'.")
EOF
```{{execute}}

Si miras el editor a tu izquierda, deberías ver los tres archivos que hemos creado.