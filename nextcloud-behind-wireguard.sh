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
echo -e " ${GRAYB}#${ENDCOLOR} ${GRAYB} !!! This addon is for Debian 12 only !!!                                                                                           ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${RED}Not finished, just a collections of ideas, but shoud work for now                                                                   ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}My target, a secure Nextcloud instance, behind wireguard.                                                                           ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}So no wiregard connection, no nextcloud connection                                                                                  ${ENDCOLOR}${GRAYB}#${ENDCOLOR}"
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR}                      Version XXXX.XX.XX -  no changelog now  8                                                                      ${GRAYB}#${ENDCOLOR}"
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

#if [[ "$ID" = 'fedora' ]]; then
# if [[ "$VERSION_ID" = '38' ]]; then
#   echo -e "${GREEN}OS = Fedora ${ENDCOLOR}"
#   systemos=fedora
#   fi
#fi


if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 12. Support for Fedora maybe sometime later ${ENDCOLOR}"
   exit 1
fi



### check if script installed
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
echo -e "${GREEN}OK = Wireguard-DNScrypt-VPN-Server is installed ${ENDCOLOR}"
else
 echo -e "${RED} !!! my wireguard script is needed !!!${ENDCOLOR}"
 echo -e "${RED} Download here:  https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server${ENDCOLOR}"
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

#if [[ "$systemos" = 'fedora' ]]; then
#dnf upgrade --refresh -y && dnf autoremove -y
#dnf install httpd mod_ssl mariadb-server php-xml php-cli php-cgi php-mysqlnd php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-pecl-redis php-igbinary php-pecl-apcu memcached php-pecl-memcached unzip -y
#libmagickcore-6.q16-6-extra
#libapache2-mod-php
#systemctl enable httpd
#systemctl start httpd
#systemctl enable mariadb
#systemctl start mariadb 
#systemctl enable memcached
#systemctl start memcached
#fi


###your vars
clear
randomkey1=$(date +%s | cut -c 3-)
randomkey2=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 32  ; echo)
randomkey3=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 24  ; echo)
echo ""
echo ""
echo -e " ${GREEN}-- Your turn, make some decisions -- ${ENDCOLOR}"
echo ""
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "Your apache https port: " -e -i 23443 httpsport
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "Your mariaDB port: " -e -i 3306 dbport
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "sql databasename: " -e -i db$randomkey1 databasename
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "sql databaseuser: " -e -i dbuser$randomkey1 databaseuser
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "sql databaseuserpasswd: " -e -i $randomkey2 databaseuserpasswd
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "nextcloud logtimezone (TZ identifier): " -e -i Europe/Berlin ltz 
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "nextcloud default phone region (Country code): " -e -i DE dpr
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "nextcloud admin user name: " -e -i nextroot nextroot
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "nextcloud admin password : " -e -i $randomkey3 nextpass
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "nextcloud data folder : " -e -i  /opt/nextcloud_data ncdatafolder
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"


#if [[ "$systemos" = 'fedora' ]]; then
#mkdir -p /etc/ssl/private
#fi

### self-signed  certificate
openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=DE/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1"



### apache part
if [[ "$systemos" = 'debian' ]]; then
a2enmod ssl
a2enmod rewrite
a2enmod headers
fi

#if [[ "$systemos" = 'fedora' ]]; then
#fi


if [[ "$systemos" = 'debian' ]]; then
systemctl stop apache2.service
fi

#if [[ "$systemos" = 'fedora' ]]; then
#systemctl stop httpd.service
#fi



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


mkdir -p $ncdatafolder
cd /var/www
curl -o nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip
unzip -qq nextcloud.zip


chown -R www-data:www-data /var/www/nextcloud
chown -R www-data:www-data $ncdatafolder

##php settings nextcloud
cp /etc/php/8.2/apache2/php.ini /etc/php/8.2/apache2/php.ini.bak
sed -i "s/memory_limit = 128M/memory_limit = 1G/" /etc/php/8.2/apache2/php.ini
sed -i "s/output_buffering =.*/output_buffering = '0'/" /etc/php/8.2/apache2/php.ini
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


a2ensite nc.conf

if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

#if [[ "$systemos" = 'fedora' ]]; then
#systemctl start httpd.service
#fi


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


echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
echo " Your database server will now be hardened - just follow the instructions."
echo " Keep in mind: your MariaDB root password is still NOT set !"
echo -e "${YELLOW} You should set a root password, when asked${ENDCOLOR}"
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
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

#if [[ "$systemos" = 'fedora' ]]; then
#systemctl restart mariadb.service
#fi


(crontab -l ; echo "*/5  *  *  *  * sudo -u www-data php -f /var/www/nextcloud/cron.php") | sort - | uniq - | crontab -

cat <<EOF >> /var/www/nextcloud/config/myextra.config.php
<?php
\$CONFIG = array (
   'memcache.local' => '\OC\Memcache\APCu',
   'memcache.locking' => '\OC\Memcache\Memcached',
   'default_phone_region' => '$dpr',
   'skeletondirectory' => '',
);
EOF
echo ""
echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
echo -e "${GREEN}Wait please, nextcloud occ setup is in progress....${ENDCOLOR}"
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
cd /var/www/nextcloud
sudo -u www-data php occ maintenance:install --database "mysql" --database-name "$databasename"  --database-user "$databaseuser" --database-pass "$databaseuserpasswd" --database-host "localhost:$dbport" --admin-user "$nextroot" --admin-pass "$nextpass" --data-dir "$ncdatafolder"
sudo -u www-data php occ config:system:set logtimezone --value="$ltz"
sudo -u www-data php occ config:system:set trusted_domains 1 --value=10.$ipv4network.1
sudo -u www-data php occ app:enable encryption
sudo -u www-data php occ encryption:enable
sudo -u www-data php occ encryption:encrypt-all
#sudo -u www-data php occ encryption:enable-master-key
# 2023.08 E2EE really not working as it should??? sudo -u www-data php occ app:enable end_to_end_encryption
sudo -u www-data php occ background:cron


if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

#if [[ "$systemos" = 'fedora' ]]; then
#systemctl start httpd.service
#fi

echo "--------------------------------------------------------------------------------------------------------"
echo " E2EE end 2 end encryption is not working like usual without, functions too limited .......2023.08 "
echo " Used serverside encryption for now, less secure but better than nothing ..... "
echo " A cloud VPS server is not really your host, its just someone else system,storage,and so on ......"
echo "--------------------------------------------------------------------------------------------------------"
echo ""
echo ""
echo -e "${GREEN} Your settings, and passwords, maybe take a copy ..... ${ENDCOLOR}"
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------"
echo " Your apache https port         :  $httpsport"
echo "--------------------------------------------------------------------------------------------------------"
echo " Your mariaDB port              :  $dbport"
echo "--------------------------------------------------------------------------------------------------------"
echo " sql databasename               :  $databasename"
echo "--------------------------------------------------------------------------------------------------------"
echo " sql databaseuser               :  $databaseuser"
echo "--------------------------------------------------------------------------------------------------------"
echo " sql databaseuserpasswd         :  $databaseuserpasswd"
echo "--------------------------------------------------------------------------------------------------------"
echo " Your nextcloud data folder     :  $ncdatafolder"
echo "--------------------------------------------------------------------------------------------------------"
echo " Your nextcloud admin user      :  $nextroot"
echo "--------------------------------------------------------------------------------------------------------"
echo " Your nextcloud login password  :  $nextpass"
echo "--------------------------------------------------------------------------------------------------------"
echo " Now setup Nextcloud to your needs  :  https://10.$ipv4network.1:$httpsport"
echo "--------------------------------------------------------------------------------------------------------"
echo ""
echo ""

