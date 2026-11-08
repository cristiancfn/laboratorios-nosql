# Paso 4: Diseño del Proceso MapReduce en Python (Mapper y Reducer)

El objetivo de nuestro proceso **MapReduce** es transformar los 50,000 eventos crudos de `/datalake/raw/pos_logs/raw_pos_transactions.log` en una **Tabla de Hechos Diaria (`fact_ventas_diarias`)** lista para cargarse en un Modelo Dimensional (Esquema en Estrella).

### ¿Cómo funciona el grano de la Tabla de Hechos que vamos a construir?
* **Llaves Foráneas hacia las Dimensiones (Clave Compuesta):**
  * `id_fecha` (Numérico entero en formato `YYYYMMDD`, ej. `20261015`. En modelado dimensional, usar una llave subrogada entera inteligente para `dim_fecha` optimiza los índices, acelera los `JOIN` y facilita el particionamiento cronológico).
  * `id_tienda` (Ej. `TIENDA_BOG_01`)
  * `id_producto` (Ej. `PROD_CAFE_500G`)
  * `metodo_pago` (Normalizado en mayúsculas, ej. `EFECTIVO`)
* **Métricas Aditivas (Hechos / Measures):**
  * `cantidad_transacciones` (Conteo de ventas exitosas)
  * `unidades_vendidas` (Suma de unidades del producto)
  * `ingreso_bruto_total` (Suma monetaria total vendida)

---

### 4.1 Crear la fase `Mapper` (`mapper.py`)

En **Hadoop Streaming**, el script `mapper.py` lee el archivo línea por línea desde la entrada estándar (`sys.stdin`). Por cada línea:
1. Valida que tenga exactamente 8 columnas (descarta líneas corruptas).
2. Filtra únicamente las ventas con estado `COMPLETED`.
3. Extrae la fecha descartando la hora y elimina los guiones para obtener la llave numérica `YYYYMMDD` (además de validar que sea un entero válido), y convierte el método de pago a mayúsculas (`UPPERCASE`).
4. Emite hacia la salida estándar (`stdout`) una tupla separada por un tabulador (`\t`):
   * **Clave (`Key`):** `id_fecha,tienda,producto,metodo_pago`
   * **Valor (`Value`):** `1,cantidad,monto` (donde `1` representa una transacción).

Crea el directorio de scripts y genera el archivo `/root/mapreduce/mapper.py`:

```bash
mkdir -p /root/mapreduce

cat << 'EOF' > /root/mapreduce/mapper.py
#!/usr/bin/env python3
import sys

for linea in sys.stdin:
    linea = linea.strip()
    if not linea:
        continue
        
    campos = linea.split("|")
    
    # 1. Regla de Calidad: Descartar registros corruptos que no tengan las 8 columnas
    if len(campos) != 8:
        continue
        
    fecha_hora, tienda, producto, categoria, cantidad_str, monto_str, metodo_pago, estado = campos
    
    # 2. Regla de Negocio: Procesar únicamente transacciones efectivamente completadas
    if estado != "COMPLETED":
        continue
        
    try:
        # 3. Transformación y Estandarización
        # Convertir 'YYYY-MM-DD HH:MM:SS' en llave entera YYYYMMDD (ej. 20261015)
        fecha_limpia = fecha_hora.split(" ")[0].replace("-", "")
        id_fecha = int(fecha_limpia)
        
        metodo_limpio = metodo_pago.strip().upper()
        cantidad = int(cantidad_str)
        monto = float(monto_str)
        
        # 4. Construir Llave Compuesta Dimensional y Valores Métricos
        llave_compuesta = f"{id_fecha},{tienda},{producto},{metodo_limpio}"
        valores = f"1,{cantidad},{monto:.2f}"
        
        # Emitir par Clave \t Valor
        print(f"{llave_compuesta}\t{valores}")
        
    except ValueError:
        # Si la fecha o algún valor numérico está malformado, se ignora el registro
        continue
EOF

chmod +x /root/mapreduce/mapper.py
```{{exec}}

---

### 4.2 Crear la fase `Reducer` (`reducer.py`)

Entre el `Mapper` y el `Reducer`, Hadoop ejecuta automáticamente la fase de **Shuffle & Sort**: agrupa y ordena todas las salidas del Mapper por su **Clave (`Key`)**. Al haber transformado `id_fecha` al formato numérico `YYYYMMDD`, el ordenamiento lexicográfico coincide exactamente con el orden cronológico.

Gracias a ese ordenamiento garantizado, el `reducer.py` puede usar la técnica de **corte de control** (manteniendo solo una llave en memoria a la vez) para sumar las transacciones, las unidades y los montos de cada combinación única de `(id_fecha, Tienda, Producto, Método de Pago)`:

```bash
cat << 'EOF' > /root/mapreduce/reducer.py
#!/usr/bin/env python3
import sys

llave_actual = None
total_transacciones = 0
total_unidades = 0
total_ingresos = 0.0

for linea in sys.stdin:
    linea = linea.strip()
    if not linea:
        continue
        
    partes = linea.split("\t")
    if len(partes) != 2:
        continue
        
    llave, valores = partes
    
    try:
        tx_str, unidades_str, monto_str = valores.split(",")
        tx = int(tx_str)
        unidades = int(unidades_str)
        monto = float(monto_str)
    except ValueError:
        continue
        
    # Si seguimos en la misma llave compuesta, acumulamos las métricas
    if llave == llave_actual:
        total_transacciones += tx
        total_unidades += unidades
        total_ingresos += monto
    else:
        # Si cambió la llave (y no es la primera iteración), emitimos el acumulado anterior
        if llave_actual is not None:
            print(f"{llave_actual},{total_transacciones},{total_unidades},{total_ingresos:.2f}")
            
        # Reiniciamos acumuladores para la nueva llave
        llave_actual = llave
        total_transacciones = tx
        total_unidades = unidades
        total_ingresos = monto

# Emitir el último grupo al finalizar el archivo
if llave_actual is not None:
    print(f"{llave_actual},{total_transacciones},{total_unidades},{total_ingresos:.2f}")
EOF

chmod +x /root/mapreduce/reducer.py
```{{exec}}

---

### 4.3 Prueba Unitaria en Local (Simulando MapReduce con Tuberías Unix)

Una regla de oro en ingeniería de datos es **nunca enviar un trabajo MapReduce a YARN sin antes probarlo en local con una muestra pequeña**. 

En Linux, el comando `cat archivo | ./mapper.py | sort -k1,1 | ./reducer.py` emula exactamente el ciclo completo `Input -> Map -> Shuffle & Sort -> Reduce`.

1. Primero, observa qué emite el **Mapper** con las primeras 20 líneas del archivo (fíjate cómo `id_fecha` ya sale como un entero de 8 dígitos `YYYYMMDD`):

```bash
head -n 20 /root/raw_pos_transactions.log | /root/mapreduce/mapper.py
```{{exec}}

2. Ahora, ejecuta el flujo completo (`Map -> Sort -> Reduce`) sobre las primeras 500 líneas y observa cómo se generan filas limpias separadas por comas:

```bash
head -n 500 /root/raw_pos_transactions.log | /root/mapreduce/mapper.py | sort -k1,1 | /root/mapreduce/reducer.py | head -n 15
```{{exec}}