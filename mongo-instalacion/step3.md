Ahora que MongoDB está corriendo, vamos a ingresar a la consola (Mongo Shell) para crear nuestro primer usuario administrador.

Entra a la Mongo Shell:
`mongosh`{{execute}}

Una vez dentro, cambia a la base de datos `admin`:
`use admin`{{execute}}

Crea el usuario administrador ejecutando este comando:
```javascript
db.createUser({
  user: "admin",
  pwd: "password123",
  roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" } ]
})
```{{execute}}

Sal de la consola de MongoDB:
`exit`{{execute}}