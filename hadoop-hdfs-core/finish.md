# Fin del Laboratorio

¡Felicitaciones! Has interactuado exitosamente con la arquitectura a bajo nivel de Apache Hadoop. 

Has logrado:
* Inicializar y auditar los daemons Java del clúster (JPS).
* Navegar por el sistema de archivos distribuido a través de la CLI.
* Ejecutar el pipeline de escritura (put).
* Auditar el NameNode y comprobar empíricamente la fragmentación estricta de 128 MB.

### Reflexión de Cierre
Vuelve a la sesión principal con tu profesor para la discusión final: 

Si tuviéramos 3 servidores reales, y estuviéramos escribiendo este archivo con un factor de replicación de 3... **¿Qué ocurriría físicamente si desconectamos el cable de poder del DataNode 2 justo en el segundo en que está recibiendo el remanente del Bloque B?** 

Prepárate para discutir sobre *Tolerancia a Fallos* y *Heartbeats*.