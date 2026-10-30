### Fase 3: Replicación Asíncrona, Rol del Árbitro e Idempotencia del Oplog

Vamos a demostrar empíricamente tres pilares arquitectónicos vistos en clase: la lectura en secundarios, la ausencia de datos en el Árbitro y la transformación idempotente de operaciones en el **Oplog (`local.oplog.rs`)**.

#### Paso 1: Escritura y actualización relativa (`$inc`) en el Primario
Conectémonos al Primario (`nodo1:27017`), insertemos una cuenta bancaria con `saldo: 100` y luego apliquemos un incremento relativo de `50` usando el operador `$inc`:

```bash
mongosh --host nodo1 --port 27017 --eval '
  const dbProd = db.getSiblingDB("banco_db");
  dbProd.cuentas.insertOne({ _id: "CTA-001", titular: "Cristian", saldo: 100 });
  dbProd.cuentas.updateOne({ _id: "CTA-001" }, { $inc: { saldo: 50 } });
  print("✅ Documento insertado y actualizado en el Primario:");
  printjson(dbProd.cuentas.findOne({ _id: "CTA-001" }));
'
```{{execute}}

---

#### Paso 2: Lectura en el Nodo Secundario (`setReadPref`)
Por defecto, MongoDB bloquea las lecturas directas en nodos secundarios para prevenir *Stale Reads* (lecturas obsoletas). Si nos conectamos a `nodo2:27018`, debemos habilitar `setReadPref('secondary')` para verificar que el documento y su saldo de `150` se replicaron correctamente:

```bash
mongosh --host nodo2 --port 27018 --eval '
  db.getMongo().setReadPref("secondary");
  const dbSec = db.getSiblingDB("banco_db");
  print("📄 Datos leídos directamente desde el SECUNDARIO (nodo2):");
  printjson(dbSec.cuentas.find().toArray());
'
```{{execute}}

---

#### Paso 3: Comprobar la naturaleza ligera del Árbitro (Cero Datos)
Conectémonos ahora a `arbitro:27019` e intentemos consultar las colecciones de `banco_db`:

```bash
mongosh --host arbitro --port 27019 --eval '
  db.getMongo().setReadPref("secondary");
  try {
    db.getSiblingDB("banco_db").getCollectionNames();
  } catch (e) {
    print("🚫 El Árbitro rechazó la lectura de datos:");
    print("   " + e.name + ": " + e.message);
  }
'
```{{execute}}

Observa el error `MongoServerError: node is not in primary or recovering state`: como el nodo está en estado `ARBITER` (ni Primario ni Secundario), el motor bloquea de raíz cualquier consulta a bases de datos de usuario.

Ahora verifiquemos el almacenamiento físico en Linux. Nota que si miras el tamaño bruto total, WiredTiger pre-asigna ~300 MB en la subcarpeta `journal/` al arrancar cualquier instancia. Pero si **excluimos el journal pre-asignado** y contamos los archivos reales de colecciones (`collection-*.wt`), la diferencia es evidente:

```bash
echo "📊 Tamaño real de datos y catálogo (excluyendo los 300MB pre-asignados de journal):"
du -sh --exclude=journal /var/lib/mongo1 /var/lib/mongo2 /var/lib/mongo_arb

echo ""
echo "📁 Cantidad de archivos de colecciones (collection-*.wt) en cada nodo:"
echo "Nodo 1 (Primario):   $(ls -1 /var/lib/mongo1/collection-*.wt 2>/dev/null | wc -l) archivos"
echo "Nodo 2 (Secundario): $(ls -1 /var/lib/mongo2/collection-*.wt 2>/dev/null | wc -l) archivos"
echo "Árbitro:             $(ls -1 /var/lib/mongo_arb/collection-*.wt 2>/dev/null | wc -l) archivos"
```{{execute}}

El Árbitro solo contiene su configuración local de inicio (1 archivo de sistema) y **no almacena ni la colección `banco_db.cuentas` ni el `oplog.rs`**.

---

#### Paso 4: Inspección del Oplog y Demostración de Idempotencia
En la teoría vimos que el Oplog debe ser **idempotente**: aplicar una entrada del Oplog una o múltiples veces debe producir exactamente el mismo resultado. Si MongoDB guardara `$inc: { saldo: 50 }` en el Oplog y este se re-ejecutara por un reintento de red, el saldo subiría a `200` por error.

Consultemos la colección `local.oplog.rs` para ver qué guardó realmente el motor bajo el capó:

```bash
mongosh --host nodo1 --port 27017 --eval '
  const oplog = db.getSiblingDB("local").oplog.rs;
  print("🔬 Últimas operaciones registradas en local.oplog.rs:");
  printjson(
    oplog.find({ ns: "banco_db.cuentas" }, { ts: 1, op: 1, ns: 1, o: 1, o2: 1 })
         .sort({ $natural: -1 })
         .limit(2)
         .toArray()
  );
'
```{{execute}}

¡Analiza el registro con `"op": "u"` (Update)! En el campo `o.diff.u` verás `{ saldo: 150 }`. MongoDB convirtió tu `$inc: { saldo: 50 }` en una asignación absoluta idempotente equivalente a `$set: { saldo: 150 }`.