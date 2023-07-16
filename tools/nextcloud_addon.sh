#!/bin/bash
clear
echo "just a thought/idea"
echo "a small/singel nextcloud environment, with access only over wireguard"
echo "without let's encrypt, just self-signed certificate"
echo "only for debian 12 and fedora 38, > out-of-the-box php 8.2"


echo ""
echo  -e "                    ${RED}To EXIT this script press any key${ENDCOLOR}"
echo ""
echo  -e "                            ${GREEN}Press [Y] , but not (N)ow :)${ENDCOLOR}"
read -p "" -n 1 -r
echo ""
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    exit 1
fi

### root check
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${RED}Sorry, you need to run this as root${ENDCOLOR}"
	exit 1
fi


#
# OS check
#
echo -e "${GREEN}OS check ${ENDCOLOR}"

. /etc/os-release

if [[ "$ID" = 'debian' ]]; then
 if [[ "$VERSION_ID" = '12' ]]; then
   echo -e "${GREEN}OS = Debian ${ENDCOLOR}"
   systemos=debian
   fi
fi

if [[ "$ID" = 'fedora' ]]; then
 if [[ "$VERSION_ID" = '38' ]]; then
   echo -e "${GREEN}OS = Fedora ${ENDCOLOR}"
   systemos=fedora
   fi
fi


if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 12, Fedora 38${ENDCOLOR}"
   exit 1
fi



### check if script installed
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
     echo ""
else
	 exit 1
fi

ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)

#
# OS updates
#
echo -e "${GREEN}update upgrade and install ${ENDCOLOR}"

if [[ "$systemos" = 'debian' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-redis php-igbinary unzip -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install httpd mod_ssl libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-redis php-igbinary unzip -y
fi


### self-signed 4096 certificate
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 3650 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=DE/ST=BY/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1" -addext "subjectAltName=IP:10.$ipv4network.1"

### apache part
a2enmod ssl
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
a2enmod setenvif


if [[ "$systemos" = 'debian' ]]; then
systemctl stop apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl stop httpd.service
fi

read -p "your apache https port: " -e -i 23443 httpsport

mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
echo "
Listen 2380

<IfModule ssl_module>
        Listen $httpsport
</IfModule>

<IfModule mod_gnutls.c>
        Listen $httpsport
</IfModule>
" >> /etc/apache2/ports.conf

echo "
<VirtualHost *:$httpsport>
   ServerName 10.$ipv4network.1
   DocumentRoot /var/www/nc-wireguard

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/nc-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/nc-selfsigned.key

<Directory /var/www/nc-wireguard/>
  Require host localhost
  Require ip 10.$ipv4network
</Directory>

</VirtualHost>
" >> /etc/apache2/sites-available/nc.conf

mkdir /var/www/nc-wireguard
chown -R www-data:www-data /var/www/nc-wireguard

echo "
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="index.css">
  <title>testseite</title>
</head>
<body>
<div class="bg"></div>
<div class="bg bg2"></div>
<div class="bg bg3"></div>
<div class="content">
<h1>Wellcome to testsite</h1>
<p>This is a placeholder<p>
<p>I'll be back, soon .....<p>
</div>
</body>
</html>
" > /var/www/nc-wireguard/index.html

echo "
html {
  height:100%;
}

body {
  margin:0;
}

.bg {
  animation:slide 10s ease-in-out infinite alternate;
  background-image: linear-gradient(-60deg, #6c3 50%, #09f 50%);
  bottom:0;
  left:-50%;
  opacity:.5;
  position:fixed;
  right:-50%;
  top:0;
  z-index:-1;
}

.bg2 {
  animation-direction:alternate-reverse;
  animation-duration:20s;
}

.bg3 {
  animation-duration:35s;
}

.content {
  background-color:rgba(255,255,255,.8);
  border-radius:.25em;
  box-shadow:0 0 .25em rgba(0,0,0,.25);
  box-sizing:border-box;
  left:50%;
  padding:10vmin;
  position:fixed;
  text-align:center;
  top:50%;
  transform:translate(-50%, -50%);
}

h1 {
  font-family:monospace;
}

@keyframes slide {
  0% {
    transform:translateX(-25%);
  }
  100% {
    transform:translateX(25%);
  }
}
" > /var/www/nc-wireguard/index.css 


echo "
<?php
	phpinfo();
?>
" > /var/www/nc-wireguard/index.php


if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl start httpd.service
fi


### DB part

if [[ "$systemos" = 'debian' ]]; then
systemctl stop mariadb.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl stop mariadb.service
fi

read -p "Your mariaDB port: " -e -i 3306 dbport
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
echo "
[mysqld]
bind-address = 127.0.0.1
port = $dbport

slow_query_log_file    = /var/log/mysql/mariadb-slow.log
long_query_time        = 10
log_slow_rate_limit    = 1000
log_slow_verbosity     = query_plan
log-queries-not-using-indexes
" > /etc/mysql/my.cnf
echo ""
echo " Your database server will now be hardened - just follow the instructions."
echo " Keep in mind: your MariaDB root password is still NOT set!"
echo ""
mysql_secure_installation


randomkey1=$(date +%s | cut -c 3-)
read -p "sql databasename: " -e -i db$randomkey1 databasename
read -p "sql databaseuser: " -e -i dbuser$randomkey1 databaseuser
randomkey2=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 32  ; echo)
read -p "sql databaseuserpasswd: " -e -i $randomkey2 databaseuserpasswd
echo "
Database
databasename : $databasename
databaseuser : $databaseuser
databaseuserpasswd : $databaseuserpasswd
#
" >> /root/mysql_database_list.txt

mysql -uroot <<EOF
CREATE DATABASE $databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER '$databaseuser'@'127.0.0.1' identified by '$databaseuserpasswd';
GRANT ALL PRIVILEGES on $databasename.* to '$databaseuser'@'127.0.0.1' identified by '$databaseuserpasswd';
FLUSH privileges;
EOF


if [[ "$systemos" = 'debian' ]]; then
systemctl start mariadb.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl start mariadb.service
fi







exit
##########################################################################
#notes
###########


#### Apache


#### Nextcloud setup
cd /var/www/nc-wireguard
curl -o nextcloud.zip https://download.nextcloud.com/server/releases/.....



####php settings



#### DB 











 

