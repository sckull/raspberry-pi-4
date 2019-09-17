Kamailio - PostgresQL

## Configure hostname.

```bash
# hostname sip.org
# vim /etc/hostname # sip.org
# echo "SIP_DOMAIN=sip.org" >> /etc/profile
```

## Install Kamailio
```bash
apt install kamailio kamailio-extra-modules kamailio-postgres-modules kamailio-presence-modules kamailio-utils-modules vim
```

## Edit File kamctlrc
**/etc/kamailio/kamctlrc**

```text
SIP_DOMAIN=sip.org
DBENGINE=PGSQL
DBHOST=localhost
DBNAME=kamailio
DBRWUSER=kamuser
DBRWPW=kampass123
DBROUSER="kamailioro"
DBROPW="kamailioro"
DBACCESSHOST=127.0.0.1

DBROOTUSER="root"
MD5="md5sum"
STORE_PLAINTEXT_PW=1
```

# Install Postgres DATABASE
```bash
apt install postgresql
```

## Configure kamdbctl.pgsql CMD.

**/usr/lib/arm-linux-gnueabihf/kamailio/kamctl/kamdbctl.pgsql**
```bash
# config vars
CMD="psql -q"
```

Verify if postgres service is running.
```
/etc/init.d/postgresql status #if not run it
```

Create user root into template1.

```bash
su - postgres
$ psql template1
template1=# CREATE USER root;
template1=# ALTER USER ROOT superuser;
```

As root user (linux) check if the user can login.
```bash
# As root user - Check if root can login
# psql template1
```

Export SIP_DOMAIN variable.
```bash
# SIP_DOMAIN Variable
export SIP_DOMAIN=sip.org
echo $SIP_DOMAIN
```


## Create kamDB
```bash
kamdbctl create

INFO: creating database kamailio ...
INFO: Core Kamailio tables succesfully created.
Install presence related tables? (y/n): y
INFO: creating presence tables into kamailio ...
INFO: Presence tables succesfully created.
Install tables for imc cpl siptrace domainpolicy carrierroute
		drouting userblacklist htable purple uac pipelimit mtree sca mohqueue
		rtpproxy rtpengine? (y/n): y
INFO: creating extra tables into kamailio ...
INFO: Extra tables succesfully created.

Configurar el archivo de configuracion de kamailio
Cambiamos las opciones de MYSQL a PGSQL (postgres), se añade el modulo de postgres, el usuario y contraseña de la base de datos kamailio.
```

Edit kamailio.cfg.

**/etc/kamailio/kamailio.cfg**

```text
!define WITH_PGSQL
!define WITH_AUTH
!define WITH_USRLOCDB
!define WITH_PRESENCE
loadmodule "db_postgres.so"
!define DBURL "postgres://kamuser:kampass123@localhost/kamailio"
#auth_db params
modparam("auth_db", "calcualte_ha1", no)
#modparam("auth_db", "password_column", "password")
```

## Install RTP PROXY
```bash
apt install rtpproxy
```

Stop the rtpproxy service.
```bash
/etc/init.d/rtpproxy stop
```

Run rtpproxy.
```bash
rtpproxy -u rtpproxy -l 192.168.1.12 -s udp:localhost:7722
```

Verify that rtpproxy is running with the user rtpproxy.
```bash
# ps -ef | grep rtpproxy
rtpproxy 15788     1  0 00:43 ?        00:00:00 rtpproxy -u rtpproxy -l 192.168.1.12 -s udp:localhost 7722
root     15793 11559  0 00:43 pts/2    00:00:00 grep rtpproxy
```


# Check Database.
```bash
# psql -U kamuser -h localhost kamailio
Contraseña para usuario kamuser: kampass123
psql (11.5 (Raspbian 11.5-1+deb10u1))
conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, bits: 256, compresión: desactivado)
Digite «help» para obtener ayuda.

kamailio=> \d #tables.

... tables everywhere ...
```

# Restart Kamailio
```bash
systemctl restart kamailio
```

Create Users
```bash
kamctl add username1 12345678
kamctl add username2 12345678
```

```bash
kamctl add 7849 12345678
kamctl add 7840 12345678
```

Following informations are required to connect to this server:

- Name: whatever
- username: username1@SERVER_IP:5060
- password: 12345678
- outbound_proxy: SERVER_IP:5060

##You can use SIP clients:
### Linux

[**blink**](http://icanblink.com/download/index.php#blink-for-debian-and-ubuntu-linux)

### Windows

[**microSIP**](https://www.microsip.org/downloads)

***

**References:**

[**nikhiljohn10**](https://github.com/nikhiljohn10/pi-sip)

[**Profesor Informático del Wallmapu**](https://www.youtube.com/watch?v=1-99rHl2Z0s)
