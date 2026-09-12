Ahora que MongoDB está corriendo, vamos a ingresar a la consola (Mongo Shell) para crear nuestro primer usuario administrador. En este paso, ingresarás los comandos de forma manual.

Primero, entra a la Mongo Shell digitando el siguiente comando en tu terminal y presionando Enter:

`mongosh`

Una vez dentro, notarás que el prompt de la terminal cambia. Ahora, cambia a la base de datos `admin` escribiendo:

`use admin`

A continuación, escribe cuidadosamente el siguiente comando para crear el usuario. Presta mucha atención a la apertura y cierre de las llaves {} y los corchetes []:

> **💡 Nota importante sobre la consola:**
> Al escribir este comando línea por línea y presionar `Enter`, notarás que el prompt normal desaparece y es reemplazado por puntos suspensivos (`...`). ¡No te preocupes, no se ha bloqueado! Esto es completamente normal e indica que MongoDB detectó que abriste una llave `{` y está esperando a que termines de escribir el resto del comando para ejecutarlo. Sigue escribiendo las siguientes líneas.

```javascript
db.createUser({
  user: "admin",
  pwd: "password123",
  roles: [ 
    { role: "userAdminAnyDatabase", db: "admin" }, 
    { role: "readWriteAnyDatabase", db: "admin" } 
  ]
})
```

Si digitaste todo correctamente, al colocar el último paréntesis }) y presionar Enter, la consola te responderá con el mensaje { ok: 1 }, confirmando que el usuario fue creado exitosamente.

Finalmente, sal de la consola de MongoDB escribiendo:

`exit`