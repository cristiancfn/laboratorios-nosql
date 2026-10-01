<div data-wait-for="file" data-file="/tmp/finished" data-text="Instalando MongoDB... (Si ves una advertencia de tiempo de espera en rojo, ignórala, el proceso continúa)."></div>

¡El entorno está listo para usarse! 🚀

El motor de base de datos se ha instalado nativamente y el servicio `mongod` ya está en ejecución. 

### Comandos sugeridos para empezar:

**Ingresar a la base de datos:**
```bash
mongosh
```

**Validar el estado del servicio en el sistema:**
```bash
systemctl status mongod
```

**Explorar el archivo de configuración:**
```bash
cat /etc/mongod.conf
```

### Conexión al clúster de MongoDB Atlas

Para realizar las prácticas, vamos a conectarnos al clúster remoto de la clase. Haz clic en el siguiente bloque para ejecutar el script de conexión. La terminal te pedirá tu usuario y tu contraseña:

```bash
read -p "Usuario: " DB_USER && read -s -p "Contraseña: " DB_PASS && echo "" && mongosh "mongodb+srv://${DB_USER}:${DB_PASS}@cluster0.3le1niv.mongodb.net/?appName=Cluster0"
```{{execute}}