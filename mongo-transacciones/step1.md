# Fase 1: Estado Natural (Auto-Commit)

Históricamente, las bases de datos NoSQL priorizaron la velocidad sobre las reglas relacionales. En el estado natural de MongoDB, cada documento se inserta o modifica de manera atómica, pero si insertamos 100,000 registros y el servidor se apaga en el registro 50,000, esos 50,000 ya están guardados en el disco duro permanentemente (Auto-commit).

Vamos a generar una carga masiva de datos para simular transacciones financieras.

### 1\. Entrar a la Base de Datos

Ejecuta el shell de MongoDB:

```bash
mongosh
```{{execute}}

Nota: Estás conectado a rs0:PRIMARY>. Esto indica que el motor tiene habilitado el registro de operaciones distribuido (Oplog).

### 2\. Generar Carga Masiva (Scripting en Consola)

MongoDB usa un motor JavaScript. Vamos a usar un bucle for para crear un arreglo gigante en memoria y luego inyectarlo todo de golpe a la colección historial.

```javascript
use banco;

let cargaMasiva = [];
for(let i = 1; i <= 100000; i++) {
    cargaMasiva.push({
        numero_transferencia: i,
        monto: Math.floor(Math.random() * 500000),
        fecha: new Date(),
        estado: "completada"
    });
}

db.historial.insertMany(cargaMasiva);
```{{execute}}

Esta operación acaba de escribir 100,000 documentos en tu disco en fracción de segundos. Sin transacciones de por medio, no hay bloqueos de recursos (locks), lo que permite esta velocidad extrema.

### 3\. Validar los datos
```javascript
db.historial.countDocuments()
```{{execute}}
