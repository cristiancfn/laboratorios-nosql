# Etapa 2A: Comparison - Estrategias de Ingesta (Individual vs Bulk)

Una vez elegido el motor en la fase de *Culling*, la etapa de **Comparison** enfrenta distintas configuraciones, patrones de acceso o diseños dentro de la tecnología seleccionada bajo condiciones idénticas de hardware.

Primero verificaremos que nuestro proceso `mongod` tiene la caché de **WiredTiger restringida a 256 MB (0.25 GB)** para simular un entorno con recursos acotados:

```bash
mongosh --quiet --eval "db.serverStatus().wiredTiger.cache['maximum bytes configured'] / (1024*1024) + ' MB'"
```{{exec}}

---

### Comparativa 1: Inserción Individual (`insertOne`) vs. Inserción por Lotes (`insertMany` / Bulk)

En aplicaciones de alta ingesta, un error común es enviar cada documento en una transacción de red independiente (*round-trip* TCP + *flush* de metadatos). Comparemos el *throughput* (documentos insertados por segundo) insertando **10.000 documentos** con ambos métodos.

> **Nota sobre `mongosh`:** Si decides escribir o pegar bloques multilínea manualmente dentro de la consola interactiva de `mongosh`, verás que el indicador cambia a puntos suspensivos (`...`) indicando que espera el cierre de llaves o paréntesis.

Ejecuta el benchmark comparativo de ingesta:

```bash
mongosh --quiet << 'EOF'
use bench_comparison
db.ingesta_individual.drop()
db.ingesta_bulk.drop()

const N = 10000;

print("1. Probando Ingesta Individual (insertOne x 10,000)...");
const t0_ind = Date.now();
for (let i = 0; i < N; i++) {
  db.ingesta_individual.insertOne({
    sensor_id: i,
    timestamp: new Date(),
    lectura: Math.random() * 100,
    payload: "datos_de_telemetria_estandar_para_prueba_de_ingesta"
  });
}
const t1_ind = Date.now();
const seg_ind = (t1_ind - t0_ind) / 1000;
const tps_ind = (N / seg_ind).toFixed(2);

print("2. Probando Ingesta por Lotes (insertMany en lotes de 1,000)...");
const t0_bulk = Date.now();
let lote = [];
for (let i = 0; i < N; i++) {
  lote.push({
    sensor_id: i,
    timestamp: new Date(),
    lectura: Math.random() * 100,
    payload: "datos_de_telemetria_estandar_para_prueba_de_ingesta"
  });
  if (lote.length === 1000) {
    db.ingesta_bulk.insertMany(lote, { ordered: false });
    lote = [];
  }
}
const t1_bulk = Date.now();
const seg_bulk = (t1_bulk - t0_bulk) / 1000;
const tps_bulk = (N / seg_bulk).toFixed(2);

print("\n================ RESULTADOS DE LA COMPARACIÓN ================");
print(`Inserción Individual : ${seg_ind.toFixed(2)} s | Throughput: ${tps_ind} docs/seg`);
print(`Inserción Bulk (1000): ${seg_bulk.toFixed(2)} s | Throughput: ${tps_bulk} docs/seg`);
print(`Factor de aceleración: ${(tps_bulk / tps_ind).toFixed(1)}x más rápido con Bulk`);
print("==============================================================");
EOF
```{{exec}}

### Análisis del resultado
Al agrupar las escrituras en lotes de 1.000 documentos, reducimos en un **99.9%** las llamadas de red cliente-servidor y permitimos que WiredTiger agrupe las modificaciones en sus estructuras en memoria antes de consolidarlas, multiplicando drásticamente los TPS sobre el mismo hardware.