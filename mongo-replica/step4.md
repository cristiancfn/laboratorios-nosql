### Fase 4: Prueba de Fuego (Failover) y el Dilema PSA (`w: "majority"`)

Llegó el momento de someter nuestro clúster a desastres reales de infraestructura.

#### Prueba 1: Caída abrupta del Nodo Primario (Failover Automático)
Simularemos un apagón súbito de energía en `nodo1` matando su proceso en Linux con `kill -9`:

```bash
PID_PRIMARIO=$(pgrep -f "mongod1.conf")
echo "💥 Matando abruptamente al Primario (PID: $PID_PRIMARIO)..."
kill -9 $PID_PRIMARIO
```{{execute}}

Con `nodo1` muerto, quedan vivos `nodo2` (1 voto) y `arbitro` (1 voto). Juntos suman **2 de 3 votos (Mayoría estricta)**. Conectémonos a `nodo2:27018` y verifiquemos cómo fue coronado automáticamente como el nuevo `PRIMARY` en menos de 12 segundos:

```bash
mongosh --host nodo2 --port 27018 --eval '
  print("👑 Estado actual del clúster tras la caída de nodo1:");
  printjson(
    rs.status().members.map(m => ({ host: m.name, estado: m.stateStr, salud: m.health }))
  );
'
```{{execute}}

¡El servicio no se interrumpió! `nodo2:27018` ahora es `PRIMARY`.

---

#### Prueba 2: Preempción por Prioridad al revivir `nodo1`
Encendamos nuevamente `nodo1`. Como configuramos `nodo1` con `priority: 2` (mayor que la `priority: 1` de `nodo2`), apenas `nodo1` se ponga al día reclamará de vuelta su trono como `PRIMARY`:

```bash
mongod --config /etc/mongod1.conf
sleep 15
mongosh --host nodo1 --port 27017 --eval '
  print("🔄 Estado tras el regreso de nodo1 (Prioridad 2):");
  printjson(
    rs.status().members.map(m => ({ host: m.name, estado: m.stateStr, salud: m.health }))
  );
'
```{{execute}}

---

#### Prueba 3: El Dilema PSA en Producción — La Trampa de `w: "majority"`
En la sesión teórica analizamos el talón de Aquiles de una arquitectura **PSA**: ¿Qué pasa cuando quien se cae NO es el Primario, sino el **Secundario (`nodo2`)**?

Apaguemos `nodo2` para dejar vivos únicamente a `nodo1` (Primario) y a `arbitro`:

```bash
PID_SECUNDARIO=$(pgrep -f "mongod2.conf")
echo "🛑 Deteniendo el nodo Secundario (PID: $PID_SECUNDARIO)..."
kill -9 $PID_SECUNDARIO
sleep 3
```{{execute}}

Observa el dilema arquitectónico:
1. **Quórum de Elección (Votos):** `nodo1` + `arbitro` = **2 de 3 votos**. Por lo tanto, `nodo1` **sigue siendo `PRIMARY`**.
2. **Quórum de Datos (Almacenamiento):** De los 2 nodos que guardan datos en disco (`nodo1` y `nodo2`), solo **1 está vivo**. La mayoría de nodos con datos es **2**.

Intentemos insertar una transacción crítica en `nodo1` exigiendo confirmación de mayoría (`writeConcern: { w: "majority", wtimeout: 5000 }`):

```bash
mongosh --host nodo1 --port 27017 --eval '
  const dbProd = db.getSiblingDB("banco_db");
  print("⏳ Intentando escribir con w: \"majority\" (Timeout de 5 segundos)...");
  try {
    dbProd.cuentas.insertOne(
      { _id: "CTA-002", titular: "Paola", saldo: 500 },
      { writeConcern: { w: "majority", wtimeout: 5000 } }
    );
  } catch (e) {
    print("❌ ERROR CAPTURADO:");
    print(e.message);
  }
'
```{{execute}}

**¡Observa cómo la escritura se congela durante 5 segundos y lanza `WriteConcernFailed: waiting for replication timed out`!** 
Aunque hay un líder activo gracias al Árbitro, el motor no puede confirmar el *Commit Point* de mayoría porque no hay un segundo disco donde respaldar el dato.

En cambio, si en plena contingencia degradamos temporalmente la escritura a `w: 1` (confirmar solo en el Primario local), la operación pasa de inmediato:

```bash
mongosh --host nodo1 --port 27017 --eval '
  const dbProd = db.getSiblingDB("banco_db");
  const res = dbProd.cuentas.insertOne(
    { _id: "CTA-003", titular: "Contingencia w:1", saldo: 300 },
    { writeConcern: { w: 1 } }
  );
  print("✅ Escritura con w: 1 completada instantáneamente:", res.acknowledged);
'
```{{execute}}

Por último, vuelve a encender `nodo2` para dejar el clúster sano y observa cómo sincroniza automáticamente los documentos pendientes desde el Oplog:

```bash
mongod --config /etc/mongod2.conf
sleep 8
mongosh --host nodo2 --port 27018 --eval '
  db.getMongo().setReadPref("secondary");
  print("✅ Documentos sincronizados en nodo2 tras recuperarse:");
  printjson(db.getSiblingDB("banco_db").cuentas.find().toArray());
'
```{{execute}}