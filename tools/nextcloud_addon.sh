#!/bin/bash
# visual text settings
RED="\e[31m"
GREEN="\e[32m"
GRAY="\e[37m"
YELLOW="\e[93m"

REDB="\e[41m"
GREENB="\e[42m"
GRAYB="\e[47m"
ENDCOLOR="\e[0m"

clear
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}Nextcloud addon to my wireguard_dnscrypt_setup.sh                                                                                   ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${RED}Not finished, just a collections of ideas -- don't run this file now.....                                                           ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}My target, a secure Nextcloud instance, behind wireguard.                                                                           ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}So no wiregard connection, no nextcloud connection                                                                                  ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR}                      Version XXXX.XX.XX -  no changelog now  6                                                                      ${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo ""
echo ""
echo ""
echo  -e "                    ${RED}To EXIT this script press any key${ENDCOLOR}"
echo ""
echo  -e "                            ${GREEN}Press [Y] to begin${ENDCOLOR}"
read -p "" -n 1 -r
echo ""
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
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
   echo -e "${RED}This script is only for Debian 12. Support on Fedora 38 is in work ......${ENDCOLOR}"
   exit 1
fi

if [[ "$systemos" = 'fedora' ]]; then
   echo -e "${RED}Support on Fedora 38 is in work, exit script here......${ENDCOLOR}"
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
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-redis php-igbinary php-apcu memcached php-memcached unzip libmagickcore-6.q16-6-extra -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
#dnf install httpd mod_ssl libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-pecl-redis php-igbinary php-pecl-apcu memcached php-pecl-memcached unzip libmagickcore-6.q16-6-extra -y
dnf install httpd mod_ssl mariadb-server php-xml php-cli php-cgi php-mysqlnd php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-pecl-redis php-igbinary php-pecl-apcu memcached php-pecl-memcached unzip -y
#libmagickcore-6.q16-6-extra
#libapache2-mod-php
systemctl enable httpd
systemctl start httpd
systemctl enable mariadb
systemctl start mariadb 
systemctl enable memcached
systemctl start memcached
fi

clear
randomkey1=$(date +%s | cut -c 3-)
randomkey2=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 32  ; echo)
randomkey3=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 24  ; echo)
echo "The following will saved in /root/nextcloud_mysql_password_list.txt"
###your vars
read -p "Your apache https port: " -e -i 23443 httpsport
echo ""
read -p "Your mariaDB port: " -e -i 3306 dbport
echo ""
read -p "nextcloud logtimezone: " -e -i Europe/Berlin ltz 
echo ""
read -p "nextcloud default phone region: " -e -i DE dpr
echo ""
read -p "nextcloud admin user name: " -e -i nextroot nextroot
echo ""
read -p "nextcloud admin password : " -e -i $randomkey3 nextpass
echo ""

###sql vars
read -p "sql databasename: " -e -i db$randomkey1 databasename
read -p "sql databaseuser: " -e -i dbuser$randomkey1 databaseuser
read -p "sql databaseuserpasswd: " -e -i $randomkey2 databaseuserpasswd


cat <<EOF >> /root/mysql_database_list.txt
!! Maybe delete this file .... !!
Apache2
port : $httpsport

Nextcloud
adminuser : $nextroot
password  : $nextpass

SQL Database
databaseport : $dbport
databasename : $databasename
databaseuser : $databaseuser
databaseuserpasswd : $databaseuserpasswd
EOF


### self-signed  certificate
#openssl req -x509 -newkey rsa:4096 -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=XX/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1"
openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=DE/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1"

### apache part
a2enmod ssl
a2enmod rewrite
a2enmod headers
#a2enmod env
#a2enmod dir
#a2enmod mime
#a2enmod setenvif


if [[ "$systemos" = 'debian' ]]; then
systemctl stop apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl stop httpd.service
fi



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


cat <<EOF >> /etc/apache2/sites-available/nc.conf
<VirtualHost *:$httpsport>
   ServerName 10.$ipv4network.1
   DocumentRoot /var/www/nextcloud
   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/nc-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/nc-selfsigned.key

<Directory /var/www/nextcloud/>
  AllowOverride All
  Require host localhost
  Require ip 10.$ipv4network
</Directory>

<IfModule mod_headers.c>
   Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</IfModule>

</VirtualHost>
EOF


mkdir -p /opt/nextcloud/data
cd /var/www
curl -o nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip
unzip -qq nextcloud.zip


chown -R www-data:www-data /var/www/nextcloud
chown -R www-data:www-data /opt/nextcloud/data

##php settings nextcloud
cp /etc/php/8.2/apache2/php.ini /etc/php/8.2/apache2/php.ini.bak
sed -i "s/memory_limit = 128M/memory_limit = 1G/" /etc/php/8.2/apache2/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/8.2/apache2/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.2/apache2/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.2/apache2/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10G/" /etc/php/8.2/apache2/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10G/" /etc/php/8.2/apache2/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php/8.2/apache2/php.ini
sed -i "s/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/" /etc/php/8.2/apache2/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=256/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=64/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=100000/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/8.2/apache2/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/8.2/apache2/php.ini
sed -i "s/max_file_uploads =.*/max_file_uploads = 20/" /etc/php/8.2/apache2/php.ini

sed -i '$aopcache.jit=1255' /etc/php/8.2/apache2/php.ini
sed -i '$aopcache.jit_buffer_size=256M' /etc/php/8.2/apache2/php.ini

sed -i '$aapc.enable_cli=1' /etc/php/8.2/apache2/php.ini
sed -i '$aapc.enable_cli=1' /etc/php/8.2/mods-available/apcu.ini
sed -i '$aopcache.jit=1255' /etc/php/8.2/mods-available/opcache.ini
sed -i '$aopcache.jit_buffer_size=256M' /etc/php/8.2/mods-available/opcache.ini


sed -i '$a[mysql]' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.allow_local_infile=On' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.allow_persistent=On' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.cache_size=2000' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.max_persistent=-1' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.max_links=-1' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.default_port=3306' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.connect_timeout=60' /etc/php/8.2/mods-available/mysqli.ini
sed -i '$amysql.trace_mode=Off' /etc/php/8.2/mods-available/mysqli.ini



cat <<EOF >> /var/www/nextcloud/phpinfotest.php
<?php
	phpinfo();
?>
EOF

a2ensite nc.conf

if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl start httpd.service
fi


### DB part


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



mysql -uroot <<EOF
CREATE DATABASE $databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
GRANT ALL PRIVILEGES on $databasename.* to '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
FLUSH privileges;
EOF


if [[ "$systemos" = 'debian' ]]; then
systemctl restart mariadb.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl restart mariadb.service
fi


(crontab -l ; echo "*/5  *  *  *  * sudo -u www-data php -f /var/www/nextcloud/cron.php") | sort - | uniq - | crontab -


cat <<EOF >> /var/www/nextcloud/config/myextra.config.php
<?php
\$CONFIG = array (
   'memcache.local' => '\OC\Memcache\APCu',
   'memcache.locking' => '\OC\Memcache\Memcached',
   'default_phone_region' => '$dpr',
);
EOF


cd /var/www/nextcloud
sudo -u www-data php occ maintenance:install --database "mysql" --database-name "$databasename"  --database-user "$databaseuser" --database-pass "$databaseuserpasswd" --database-host "localhost:$dbport" --admin-user "$nextroot" --admin-pass "$nextpass" --data-dir "/opt/nextcloud/data/"

sudo -u www-data php occ config:system:set logtimezone --value="$ltz"
sudo -u www-data php occ config:system:set trusted_domains 2 --value=10.$ipv4network.1
sudo -u www-data php occ app:enable end_to_end_encryption
sudo -u www-data php occ background:cron


if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl start httpd.service
fi

echo ""
echo ""



echo " Setup your Nextcloud           :  https://10.$ipv4network.1:$httpsport"
echo " Your database name             :  $databasename"
echo " Your database user             :  $databaseuser"
echo " Your database password         :  $databaseuserpasswd"
echo " Your database host             :  localhost:$dbport"
echo " Your nextcloud data folder     :  /opt/nextcloud/data"
echo " Your nextcloud admin user      :  $nextroot"
echo " Your nextcloud login password  :  $nextpass"
