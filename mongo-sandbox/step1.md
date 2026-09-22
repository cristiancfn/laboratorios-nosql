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