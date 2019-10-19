![image](https://ngrok.com/static/img/demo.png)

`Ventanade CODE2 es Apache2 corriendo en el Raspberry Pi y la ventana Bash, ngrok.`

### Instalacion de Apache2
`sudo apt-get update && sudo apt-get install apache2`

### Instalar Pagina Web (Ordenes.zip) en /var/www/html/

`sudo unzip Ordenes.zip -d /var/www/html/`

### Crear una cuenta en ngrok
Descargar ngrok - **ngrok-stable-linux-arm.zip**

Descomprimir **ngrok-stable-linux-arm.zip**

`unzip ngrok-stable-linux-arm.zip`

#### Verificar cuenta de ngrok - Token
`./ngrok authtoken <TOKEN>`

#### Iniciar ngrok en el puerto 80 (Puerto de Apache)
`./ngrok http 80`

#### Iniciar ngrok/serveo al iniciar Raspberry
#### Agregar al archivo /etc/rc.local antes del 'exit 0'

`/home/pi/proyecto/ngrok/ngrok http 80`
`ssh -R myalias:22:localhost:22 serveo.net`

#### Para conexion con el raspberry atravez del servicio SSH utilizar el comando.
 
`ssh -J serveo.net user@myalias`

Donde **user** es el usuario local del Raspberry.

#### Usuarios
Para ver los usuarios conectados en el servicio de SSH utilizamos el comando

`w`

Donde los valores **tty** son las sesiones directas (locales) y **pts** las esclavas o del tipo ssh.



