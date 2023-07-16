#!/bin/bash
clear
echo "just a thought/idea"
echo "a small/singel nextcloud environment, with access only over wireguard"
echo "without let's encrypt, just self-signed 4096 certificate"


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

if [[ "$ID" = 'ubuntu' ]]; then
 if [[ "$VERSION_ID" = '22.04' ]]; then
   echo -e "${GREEN}OS = Ubuntu ${ENDCOLOR}"
   systemos=ubuntu
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
   echo -e "${RED}This script is only for Debian 12, Ubuntu 22.04, Fedora 38${ENDCOLOR}"
   exit 1
fi

#
# Architecture check for dnsscrpt 
#
ARCH=$(uname -m)
if [[ "$ARCH" == x86_64* ]]; then
  dnsscrpt_arch=x86_64
elif [[ "$ARCH" == aarch64* ]]; then
    dnsscrpt_arch=arm64
else
   echo -e "${RED}This script is only for x86_64 or ARM64  Architecture !${ENDCOLOR}"
   exit 1
fi
echo -e "${GREEN}Arch = $dnsscrpt_arch ${ENDCOLOR}"



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
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip unzip -y
fi

if [[ "$systemos" = 'ubuntu' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip unzip -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install httpd mod_ssl libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip unzip -y
fi



##########################################################################
#notes
###########

a2enmod ssl
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
a2enmod setenvif

sudo openssl req -x509 -nodes -days 1825 -newkey rsa:4096 -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt

<VirtualHost 10.$ipv4network.1:23443>
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
>> /etc/apache2/sites-available/nc.conf

read -p "mariaDB -port: " -e -i 3306 dbport


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
CREATE USER '$databaseuser'@'10.$ipv4network.%' identified by '$databaseuserpasswd';
GRANT ALL PRIVILEGES on $databasename.* to '$databaseuser'@'10.$ipv4network.%' identified by '$databaseuserpasswd';
FLUSH privileges;
EOF



mysql_secure_installation


mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
echo "
[mysqld]
bind-address = 10.$ipv4network.1
port = $dbport

slow_query_log_file    = /var/log/mysql/mariadb-slow.log
long_query_time        = 10
log_slow_rate_limit    = 1000
log_slow_verbosity     = query_plan
log-queries-not-using-indexes

" > /etc/mysql/my.cnf

mkdir /var/www/nc-wireguard
chown -R www-data:www-data /var/www/nc-wireguard
cd /var/www/nc-wireguard
curl -o nextcloud.zip https://download.nextcloud.com/server/releases/.....

a2ensite nc.conf

 

