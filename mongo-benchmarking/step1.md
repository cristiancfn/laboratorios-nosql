# Etapa 1: Culling (Descarte Arquitectónico y Funcional)

La primera fase de un benchmark (**Culling**) busca filtrar candidatos de forma temprana usando criterios funcionales y arquitectónicos antes de invertir horas en pruebas de carga masivas.

### Caso de Uso y SLA Funcional
Debemos almacenar eventos de telemetría de una flota de vehículos (`vehiculo_id`, `velocidad`, `temperatura`, `zona`) y responder en menos de **50 ms** la siguiente consulta operativa:
> *"Obtener todos los eventos donde la `temperatura` supere los 85 °C en la `zona: 'Norte'`".*

---

### 1. Verificación del entorno
Comprueba que tanto **Redis** (arquitectura Clave-Valor) como **MongoDB** (arquitectura Documental) están ejecutándose:

```bash
redis-cli ping && mongosh --quiet --eval "db.runCommand({ connectionStatus: 1 }).ok"
```{{exec}}

---

### 2. Prueba en Arquitectura Clave-Valor (Redis)
En un motor Clave-Valor puro, el acceso por clave primaria (`GET telemetry:1001`) tiene complejidad $O(1)$ y es extremadamente veloz. Sin embargo, insertemos 10.000 registros de telemetría en Redis y veamos qué ocurre cuando necesitamos filtrar por un atributo interno sin clave directa:

```bash
python3 - << 'EOF'
import redis, json, time, random

r = redis.Redis(host='127.0.0.1', port=6379, decode_responses=True)
r.flushall()

# Ingesta rápida con pipeline
pipe = r.pipeline()
for i in range(10000):
    payload = {"vehiculo_id": i, "temperatura": random.randint(60, 100), "zona": random.choice(["Norte", "Sur", "Centro"])}
    pipe.set(f"evento:{i}", json.dumps(payload))
pipe.execute()

# Intento de consulta por atributos secundarios (sin módulos externos)
t0 = time.perf_counter()
encontrados = 0
for key in r.scan_iter("evento:*"):
    doc = json.loads(r.get(key))
    if doc["temperatura"] > 85 and doc["zona"] == "Norte":
        encontrados += 1
t1 = time.perf_counter()

print(f"[Redis Clave-Valor] Documentos encontrados: {encontrados}")
print(f"[Redis Clave-Valor] Tiempo de búsqueda secundaria (10k docs): {(t1-t0)*1000:.2f} ms")
EOF
```{{exec}}

Observa cómo para apenas **10.000 registros**, Redis Clave-Valor puro nos obliga a recorrer el espacio de claves (`SCAN`), transferir cada valor por red al cliente y deserializar el JSON en la aplicación, superando el umbral de latencia exigido o obligándonos a construir y mantener índices invertidos manuales con `SETS` y `ZSETS`.

---

### 3. Prueba equivalente en Arquitectura Documental (MongoDB)
Ahora ejecutemos exactamente el mismo escenario sobre **MongoDB**, aprovechando su soporte nativo para documentos BSON e índices secundarios compuestos:

```bash
mongosh --quiet << 'EOF'
use bench_culling
db.eventos.drop()

const zonas = ["Norte", "Sur", "Centro"];
const bulk = [];
for (let i = 0; i < 10000; i++) {
  bulk.push({
    vehiculo_id: i,
    temperatura: Math.floor(Math.random() * 41) + 60,
    zona: zonas[i % 3]
  });
}
db.eventos.insertMany(bulk);
db.eventos.createIndex({ zona: 1, temperatura: 1 });

const stats = db.eventos.find({ zona: "Norte", temperatura: { $gt: 85 } }).explain("executionStats");
print("[MongoDB Documental] Documentos encontrados:", stats.executionStats.nReturned);
print("[MongoDB Documental] Documentos examinados:", stats.executionStats.totalDocsExamined);
print("[MongoDB Documental] Tiempo de ejecución interna:", stats.executionStats.executionTimeMillis, "ms");
EOF
```{{exec}}

### Decisión de la Etapa de Culling
* **Redis (Clave-Valor puro):** Excelente para caché por ID exacto ($O(1)$), pero **descartado (Culled)** como motor principal para consultas ad-hoc multidimensionales por atributos internos.
* **MongoDB (Documental):** Cumple el requisito funcional y resuelve la consulta en **0 a 2 ms** gracias al índice B-Tree compuesto. Pasa a la **Etapa 2 (Comparison)**.

Limpia la memoria de Redis y detén su servicio para dedicar todos los recursos de la máquina virtual a las pruebas profundas sobre MongoDB:

```bash
redis-cli flushall && systemctl stop redis-server
```{{exec}}