# Etapa 2B: Comparison - Diseño de Índices y Presión en RAM

En esta segunda prueba de la fase **Comparison**, evaluaremos cómo el diseño de la clave indexada impacta el uso de la caché de **WiredTiger** y el rendimiento de inserción y consulta:

* **Candidato A (Clave Secuencial / Monótona):** Los valores nuevos siempre se insertan al final del árbol B-Tree (alta localidad espacial en memoria).
* **Candidato B (Clave Aleatoria / UUID):** Cada inserción cae en una página distinta del árbol B-Tree, obligando a tocar y dividir páginas (*page splits*) a lo largo de todo el índice.

Ejecuta la prueba comparativa con **80.000 documentos** indexados en cada colección:

```bash
mongosh --quiet << 'EOF'
use bench_comparison
db.idx_secuencial.drop()
db.idx_aleatorio.drop()

// Creamos el índice antes de la carga para medir el costo real de mantenimiento del B-Tree
db.idx_secuencial.createIndex({ codigo_evento: 1 })
db.idx_aleatorio.createIndex({ codigo_evento: 1 })

const TOTAL = 80000;
const LOTE = 2000;

print("1. Insertando 80,000 docs con clave SECUENCIAL indexada...");
const t0_sec = Date.now();
for (let b = 0; b < TOTAL / LOTE; b++) {
  let batch = [];
  for (let i = 0; i < LOTE; i++) {
    let seq = (b * LOTE) + i;
    batch.push({
      codigo_evento: "EVT-" + String(seq).padStart(10, '0'),
      valor: i,
      relleno: "X".repeat(120)
    });
  }
  db.idx_secuencial.insertMany(batch, { ordered: false });
}
const t_sec = (Date.now() - t0_sec) / 1000;

print("2. Insertando 80,000 docs con clave ALEATORIA indexada...");
const t0_rnd = Date.now();
for (let b = 0; b < TOTAL / LOTE; b++) {
  let batch = [];
  for (let i = 0; i < LOTE; i++) {
    let rnd = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    batch.push({
      codigo_evento: "EVT-" + rnd,
      valor: i,
      relleno: "X".repeat(120)
    });
  }
  db.idx_aleatorio.insertMany(batch, { ordered: false });
}
const t_rnd = (Date.now() - t0_rnd) / 1000;

const stats_sec = db.idx_secuencial.stats();
const stats_rnd = db.idx_aleatorio.stats();

print("\n================ COMPARACIÓN DE ÍNDICES B-TREE ================");
print(`Clave Secuencial -> Tiempo: ${t_sec.toFixed(2)} s | Tamaño Índice: ${(stats_sec.totalIndexSize / (1024*1024)).toFixed(2)} MB`);
print(`Clave Aleatoria  -> Tiempo: ${t_rnd.toFixed(2)} s | Tamaño Índice: ${(stats_rnd.totalIndexSize / (1024*1024)).toFixed(2)} MB`);
print("===============================================================");
EOF
```{{exec}}

### ¿Qué debes observar en la métrica?
1. **Tamaño del índice (`totalIndexSize`):** El índice con claves aleatorias ocupa significativamente más espacio en RAM y disco debido a la fragmentación interna causada por las divisiones de página (*page splits* al 50%) y a una menor tasa de compresión por prefijos (*prefix compression*) en WiredTiger.
2. **Tiempo de inserción:** A medida que el árbol B-Tree crece, las claves aleatorias degradan la velocidad de ingesta porque impiden aprovechar las mismas páginas calientes en la caché.

Elimina las bases de datos de las pruebas anteriores para dejar limpia la caché de WiredTiger antes de la prueba final de escalabilidad:

```bash
mongosh --quiet --eval "db.getSiblingDB('bench_culling').dropDatabase(); db.getSiblingDB('bench_comparison').dropDatabase();"
```{{exec}}