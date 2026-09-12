El usuario está creado, pero MongoDB aún no exige autenticación. Debemos habilitarla en el archivo `mongod.conf`.

Usa el siguiente comando para descomentar y habilitar la sección de seguridad:
`sudo sed -i 's/#security:/security:\n  authorization: enabled/' /etc/mongod.conf`{{execute}}

*(Nota: También puedes usar `nano /etc/mongod.conf` si prefieres hacerlo manualmente. Es necesario retirar el numeral antes de la sección security, y debajo de security (con la debida indentación de dos espacios) habilitar la opción authorization: enabled).*

Para que los cambios surtan efecto, debemos reiniciar el servicio:
`sudo systemctl restart mongod`{{execute}}

Validemos nuevamente que el servicio haya levantado correctamente:
`sudo systemctl status mongod`{{execute}}

Finalmente, intenta entrar a la Mongo Shell con el usuario recién creado:
`mongosh -u admin -p password123 --authenticationDatabase admin`{{execute}}

Si entras con éxito, ¡la configuración de seguridad funciona perfectamente! Puedes verificar tus privilegios ejecutando `show dbs`{{execute}}.