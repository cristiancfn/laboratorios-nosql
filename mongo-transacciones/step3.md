# Fase 3: Transacciones y MVCC (Rollback)

Ahora veremos la diferencia entre la fase 1 (donde todo se guardaba inmediatamente) y un bloque Transaccional ACID, donde exigimos la ley del "Todo o Nada".

### 1\. Estado Inicial

Creemos dos cuentas con saldos iniciales:

```javascript
db.cuentas.insertMany([
    { _id: "Cuenta_A", saldo: 1000 },
    { _id: "Cuenta_B", saldo: 1000 }
]);
```{{execute}}

### 2. Bloque Transaccional Interrumpido
A continuación, abriremos una sesión, iniciaremos la transacción y le restaremos $500 a la `Cuenta_A`. Pero, simularemos un error a la mitad del proceso abortando la transacción (MVCC destruirá el snapshot).

```javascript
// Iniciamos la sesión
const session = db.getMongo().startSession();
session.startTransaction();

// Obtenemos la colección atada a ESTA sesión
const cuentas = session.getDatabase("banco").cuentas;

// 1. Descontamos el saldo
cuentas.updateOne({ _id: "Cuenta_A" }, { $inc: { saldo: -500 } });

// Validemos el saldo DENTRO de la transacción (Snapshot aislado)
print("Saldo A dentro de la transacción: " + cuentas.findOne({ _id: "Cuenta_A" }).saldo);

// 2. ¡ERROR! El sistema falla antes de sumar el dinero a la cuenta B
print("¡Error crítico en el servidor! Abortando...");
session.abortTransaction();
session.endSession();
```{{execute}}

### 3. Comprobación Final (La magia del Rollback)
La `Cuenta_A` mostró $500 en memoria dentro de su *Snapshot* transaccional. Pero como la sesión fue abortada, MongoDB protegió la integridad de la base de datos revirtiendo el tiempo.

Validemos la realidad final de los datos en el disco:
```javascript
db.cuentas.find()
```{{execute}}

El saldo de la Cuenta_A **ha vuelto a 1000**. ¡Tu arquitectura NoSQL ha protegido los fondos del banco ante una falla del sistema!
