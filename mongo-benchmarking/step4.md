# Etapa 3: Scaling - Concurrencia y Saturación de Recursos

En la última etapa del benchmarking (**Scaling**), tomamos el diseño ganador (ingesta por lotes + índice compuesto alineado a la consulta) y medimos cómo se comporta el motor cuando **escalamos la carga concurrente** (clientes simultáneos).

### 1. Preparación del Dataset Base (100.000 documentos)
Primero poblaremos la colección `bench.lecturas_escala` con 100.000 registros y su índice correspondiente:

```bash
mongosh --quiet << 'EOF'
use bench
db.lecturas_escala.drop()

print("Generando 100,000 documentos de telemetría...");
const LOTE = 5000;
for (let b = 0; b < 20; b++) {
  let batch = [];
  for (let i = 0; i < LOTE; i++) {
    batch.push({
      sensor_id: Math.floor(Math.random() * 500) + 1,
      temperatura: Math.floor(Math.random() * 50) + 10,
      humedad: Math.floor(Math.random() * 100),
      fecha: new Date()
    });
  }
  db.lecturas_escala.insertMany(batch, { ordered: false });
}
db.lecturas_escala.createIndex({ sensor_id: 1, temperatura: 1 });
print("✅ Dataset e índice creados correctamente.");
EOF
```{{exec}}

---

### 2. Ejecución de la Curva de Escalabilidad (1, 4, 16 y 32 Hilos)

En `/root/benchmark/scale_test.py` dispones de un generador de carga multihilo en Python que mide el **Throughput (QPS)** y los percentiles de latencia (**Promedio, p95 y p99**).

Ejecutaremos 4 escalones de concurrencia consecutivos para observar la **Ley de Escalabilidad Universal** en acción:

#### Escalón 1: Línea base sin contención (1 hilo concurrente)
```bash
python3 /root/benchmark/scale_test.py 1 1000
```{{exec}}

#### Escalón 2: Paralelismo aprovechando los vCPUs (4 hilos concurrentes)
```bash
python3 /root/benchmark/scale_test.py 4 1000
```{{exec}}

#### Escalón 3: Alta concurrencia (16 hilos concurrentes)
```bash
python3 /root/benchmark/scale_test.py 16 500
```{{exec}}

#### Escalón 4: Saturación y encolamiento (32 hilos concurrentes)
```bash
python3 /root/benchmark/scale_test.py 32 300
```{{exec}}

---

### 3. Interpretación de Resultados de la Etapa de Scaling
Compara las 4 tablas impresas en tu consola y observa dos fenómenos clave:
1. **Techo de Throughput (QPS):** Al pasar de 1 a 4 hilos, las consultas por segundo (QPS) aumentan porque aprovechamos todos los núcleos virtuales de la máquina. Sin embargo, al subir a 16 y 32 hilos, el *throughput* deja de crecer (o incluso retrocede ligeramente) por el costo de cambio de contexto (*context switching*) de la CPU.
2. **Explosión de la Latencia de Cola (`p95` y `p99`):** Aunque el sistema sigue respondiendo el mismo volumen total por segundo, la latencia **p99** se multiplica varias veces en los escalones de 16 y 32 hilos debido al tiempo de espera en cola. En un benchmark profesional, este punto marca el **límite máximo de concurrencia saludable** antes de requerir escalamiento horizontal (*Sharding* o *Read Replicas*).