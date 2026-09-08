import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# 1. Simulación de la extracción granular desde el Data Warehouse
print("Generando datos simulados de clientes (Edad vs Score de Gastos)...")
np.random.seed(42)
# Generamos 3 grupos naturales de clientes
X = np.concatenate([
    np.random.normal(loc=[25, 80], scale=5, size=(100, 2)), # Jóvenes que gastan mucho
    np.random.normal(loc=[55, 30], scale=5, size=(100, 2)), # Adultos mayores conservadores
    np.random.normal(loc=[35, 50], scale=5, size=(100, 2))  # Promedio
])

df = pd.DataFrame(X, columns=['Edad', 'Score_Gasto'])

# 2. Inicialización y entrenamiento del modelo K-Means
print("Entrenando algoritmo K-Means con K=3...")
kmeans = KMeans(n_clusters=3, random_state=42)
df['Cluster'] = kmeans.fit_predict(df[['Edad', 'Score_Gasto']])

# 3. Resultados
print("\nCentroides de los Clústeres descubiertos:")
print(pd.DataFrame(kmeans.cluster_centers_, columns=['Edad Promedio', 'Score Gasto Promedio']))

# 4. Guardar un 'artefacto' visual
plt.scatter(df['Edad'], df['Score_Gasto'], c=df['Cluster'], cmap='viridis')
plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1], s=300, c='red', marker='X')
plt.title('Segmentación de Clientes - K-Means')
plt.xlabel('Edad')
plt.ylabel('Score de Gasto')
plt.savefig('clusters_output.png')
print("\nGráfico guardado como 'clusters_output.png'. Simulación finalizada exitosamente.")