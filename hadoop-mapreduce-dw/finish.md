# ¡Laboratorio Completado con Éxito!

Has implementado de principio a fin una arquitectura clásica de **Data Lake y Procesamiento Batch con Apache Hadoop**, dejando los datos listos para su modelado analítico.

---

### Resumen de lo que construiste hoy:

1. **Instalación y Configuración de Clúster Pseudo-Distribuido:** Configuraste SSH sin contraseña, variables de entorno y los archivos `core-site.xml`, `hdfs-site.xml`, `mapred-site.xml` y `yarn-site.xml`, ajustando el consumo de memoria (*Heap Size*) de la JVM para operar de forma estable en un solo servidor.
2. **Gestión de Almacenamiento en HDFS:** Estructuraste las capas `/datalake/raw` y `/datalake/refined`, cargaste el archivo transaccional de 50,000 eventos y auditaste sus bloques físicos con `hdfs fsck`.
3. **Paradigma MapReduce con Python:** Diseñaste un `mapper.py` que aplicó reglas de calidad de datos (eliminación de registros corruptos y transacciones canceladas, normalización de textos y extracción de llave compuesta) y un `reducer.py` que consolidó las métricas aditivas mediante corte de control.
4. **Puente hacia la Bodega de Datos (Data Warehouse):** Ejecutaste el trabajo distribuido sobre **YARN** y utilizaste `hdfs dfs -getmerge` para generar el archivo `fact_ventas_diarias.csv`.

---

### ¿Qué sigue en el Modelo Dimensional?

El archivo **`fact_ventas_diarias.csv`** que generaste tiene exactamente la estructura de una **Tabla de Hechos** con granularidad diaria:

| Columna en el CSV | Rol en el Esquema en Estrella (Star Schema) |
| :--- | :--- |
| `id_fecha` | Llave Foránea entera (YYYYMMDD) hacia **`dim_tiempo` / `dim_fecha`** (Año, Trimestre, Mes, Día de la semana, Es festivo). |
| `id_tienda` | Llave Foránea (FK) hacia **`dim_tienda`** (Ciudad, Región, Nombre de sucursal, Formato). |
| `id_producto` | Llave Foránea (FK) hacia **`dim_producto`** (Nombre del producto, Categoría, Precio de lista, Proveedor). |
| `metodo_pago` | Llave Foránea (FK) hacia **`dim_metodo_pago`** (Tipo de medio, Entidad bancaria, Requiere comisión). |
| `cantidad_transacciones` | **Métrica / Hecho aditivo** (Volumen de tickets). |
| `unidades_vendidas` | **Métrica / Hecho aditivo** (Unidades desplazadas). |
| `ingreso_bruto_total` | **Métrica / Hecho aditivo** (Valor monetario de las ventas). |