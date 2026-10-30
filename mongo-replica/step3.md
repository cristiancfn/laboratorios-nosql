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
Por defecto, MongoDB bloquea las lecturas directas en nodos secundarios para prevenir *Stale Reads* (lecturas obsoletas).Si nos conectamos a `nodo2:27018`, debemos habilitar `setReadPref('secondary')` para verificar que el documento y su saldo de `150` se replicaron correctamente:

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
Conectémonos ahora a `arbitro:27019` e intentemos listar las bases de datos o leer la colección `banco_db.cuentas`:

```bash
mongosh --host arbitro --port 27019 --eval '
  db.getMongo().setReadPref("secondary");
  const dbArb = db.getSiblingDB("banco_db");
  print("🔍 Colecciones dentro de banco_db en el Árbitro:");
  printjson(dbArb.getCollectionNames());
'
```{{execute}}

Observa cómo devuelve un arreglo vacío `[]`. Además, si inspeccionamos el tamaño de los directorios en Linux, verás que el Árbitro no almacena las colecciones de negocio:

```bash
du -sh /var/lib/mongo1 /var/lib/mongo2 /var/lib/mongo_arb
```{{execute}}

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

¡Analiza el registro con `"op": "u"` (Update)! En el campo `o.diff.u` verás `{ saldo: 150 }`. MongoDB convirtió tu `$inc: { saldo: 50 }` en una asignación absoluta idempotente equivalencia a `$set: { saldo: 150 }`.