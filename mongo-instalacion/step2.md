Por defecto, MongoDB solo escucha conexiones en `127.0.0.1` (localhost). Vamos a modificar el archivo de configuración para que escuche en todas las interfaces de red (`0.0.0.0`).

Usa el siguiente comando `sed` para reemplazar la IP en el archivo de configuración:
`sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf`{{execute}}

*(Nota: También puedes usar `nano /etc/mongod.conf` si prefieres hacerlo manualmente, tienes que modificar la propiedad bindIp y cambiarla de 127.0.0.1 a 0.0.0.0).*

Ahora, inicia el servicio de MongoDB y habilítalo para que inicie con el sistema:
`sudo systemctl start mongod`{{execute}}
`sudo systemctl enable mongod`{{execute}}

Verifica que el servicio esté corriendo correctamente:
`sudo systemctl status mongod`{{execute}}

*(Presiona `q` para salir del status si es necesario).*