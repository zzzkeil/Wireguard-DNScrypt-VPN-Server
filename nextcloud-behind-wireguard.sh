#!/bin/bash

msghi="This script installs and configure nextcloud \n
Nextcloud access is only over wireguard active ! \n
So no wiregard connection, no nextcloud connection \n\n
Infos @ https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server \n
Version 2025.08.xx \n\n
Run script now ?"

if whiptail --title "Hi, lets start" --yesno "$msghi" 25 90; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, no install right now. Have a nice day." 15 80
exit 1
fi  

### root check
if [[ "$EUID" -ne 0 ]]; then
whiptail --title "Aborted" --msgbox "Sorry, you need to run this as root!" 15 80
exit 1
fi

### OS check
. /etc/os-release
if [[ "$ID" = 'debian' ]]; then
 if [[ "$VERSION_ID" = '13' ]]; then
 systemos=debian
 fi
fi

if [[ "$ID" = 'ubuntu' ]]; then
 if [[ "$VERSION_ID" = '24.04' ]]; then
 systemos=ubuntu
 fi
fi

if [[ "$systemos" = '' ]]; then
whiptail --title "Aborted" --msgbox "This script is only for Debian 13 and Ubuntu 24.04 !" 15 80
exit 1
fi



### check if script installed
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
echo ""
else
whiptail --title "Aborted" --msgbox "My wireguard script not installed\nDownload here:  https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server" 15 80
 exit 1
fi

ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv4network2="${ipv4network%.*}"
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)

update_upgrade_with_gauge() {
    {
        echo 10
        echo "Starting apt-get update..."
        apt-get update -y &> /dev/null
        if [ $? -ne 0 ]; then
            echo 100
            echo "Error: apt-get update failed."
            exit 1
        fi

        echo 50
        echo "Starting apt-get upgrade..."
        apt-get upgrade -y &> /dev/null
        if [ $? -ne 0 ]; then
            echo 100
            echo "Error: apt-get upgrade failed."
            exit 1
        fi

        echo 100
        echo "Update and Upgrade completed successfully."
    } | whiptail --title "System Update and Upgrade" --gauge "Please wait while updating and upgrading the system..." 15 80 0

    if [ $? -eq 0 ]; then
       echo ""
    else
        whiptail --title "Error" --msgbox "The update/upgrade process was interrupted." 15 80
    fi
}

if [[ "$systemos" = 'debian' ]]; then
update_upgrade_with_gauge
if [ -f /var/run/reboot-required ]; then
whiptail --title "reboot-required" --msgbox "Oh dammit :) - System upgrade required a reboot!\nreboot, and run this script again" 15 80
exit 1
fi
packagesdebian=("apache2" "libapache2-mod-php" "mariadb-server" "php8.4-xml" "php8.4-cli" "php8.4-cgi" "php8.4-mysql" "php8.4-mbstring" "php8.4-gd" "php8.4-curl" "php8.4-intl" "php8.4-gmp" "php8.4-bcmath" "php8.4-imagick" "php8.4-zip" "php8.4-bz2" "php8.4-opcache" "php8.4-common" "php8.4-redis" "php8.4-igbinary" "php8.4-apcu" "memcached" "php8.4-memcached" "unzip" "libmagickcore-7.q16-10-extra")
install_multiple_packages_with_gauge_debian() {
    total=${#packagesdebian[@]}
    step=0

    {
        for pkg in "${packagesdebian[@]}"; do
            percent=$(( (step * 100) / total ))
            echo $percent
            echo "Installing package: $pkg..."
            sudo apt-get install -y "$pkg" &> /dev/null
            if [ $? -ne 0 ]; then
                echo 100
                echo "Error: Installation of package $pkg failed."
                exit 1
            fi
            step=$((step + 1))
        done
        echo 100
        echo "All packages installed successfully."
    } | whiptail --title "Installing needed OS Packages" --gauge "Please wait while installing packages...\napache, php, ...." 15 90 0

    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "Error" --msgbox "Installation process interrupted or failed." 15 80
		exit 1
    fi
}

install_multiple_packages_with_gauge_debian
fi


if [[ "$systemos" = 'ubuntu' ]]; then
add-apt-repository ppa:ondrej/apache2 -y
add-apt-repository ppa:ondrej/php -y
update_upgrade_with_gauge
if [ -f /var/run/reboot-required ]; then
whiptail --title "reboot-required" --msgbox "Oh dammit :) - System upgrade required a reboot!\nreboot, and run this script again" 15 80
exit 1
fi
packagesubuntu=("apache2" "libapache2-mod-php" "mariadb-server" "php8.4-xml" "php8.4-cli" "php8.4-cgi" "php8.4-mysql" "php8.4-mbstring" "php8.4-gd" "php8.4-curl" "php8.4-intl" "php8.4-gmp" "php8.4-bcmath" "php8.4-imagick" "php8.4-zip" "php8.4-bz2" "php8.4-opcache" "php8.4-common" "php8.4-redis" "php8.4-igbinary" "php8.4-apcu" "memcached" "php8.4-memcached" "unzip" "libmagickcore-6.q16-7-extra")
install_multiple_packages_with_gauge_ubuntu() {
    total=${#packagesubuntu[@]}
    step=0

    {
        for pkg in "${packagesubuntu[@]}"; do
            percent=$(( (step * 100) / total ))
            echo $percent
            echo "Installing package: $pkg..."
            sudo apt-get install -y "$pkg" &> /dev/null
            if [ $? -ne 0 ]; then
                echo 100
                echo "Error: Installation of package $pkg failed."
                exit 1
            fi
            step=$((step + 1))
        done
        echo 100
        echo "All packages installed successfully."
    } | whiptail --title "Installing needed OS Packages" --gauge "Please wait while installing packages...\napache, php, ...." 15 90 0

    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "Error" --msgbox "Installation process interrupted or failed." 15 80
		exit 1
    fi
}

install_multiple_packages_with_gauge_ubuntu
fi


systemctl stop mariadb.service
###your vars
clear
randomkey1=$(date +%s | cut -c 3-)
randomkey2=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 32  ; echo)
randomkey3=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 24  ; echo)

while true; do
    httpsport=$(whiptail --title "Apache HTTPS Port" --inputbox "Your apache https port (don't use 8443):" 10 80 "4443" 3>&1 1>&2 2>&3)
    if ss -tuln | grep -q ":$httpsport"; then
        whiptail --title "Port Check" --msgbox "Port $httpsport is already in use. Please choose another port." 10 80
    else
        break
    fi
done
while true; do
    dbport=$(whiptail --title "MariaDB port:" --inputbox "Your MariaDB port:" 10 60 "3306" 3>&1 1>&2 2>&3)
    if ss -tuln | grep -q ":$dbport"; then
        whiptail --title "Port Check" --msgbox "Port $dbport is already in use. Please choose another port." 10 80
    else
        break
    fi
done
while true; do
    ltz=$(whiptail --title "Nextcloud Log Timezone" --inputbox "Nextcloud log timezone (TZ identifier):" 10 80 "Europe/Berlin" 3>&1 1>&2 2>&3)
    if timedatectl list-timezones | grep -q "^$ltz$"; then
        break
    else
        whiptail --title "Timezone Check" --msgbox "Invalid timezone: $ltz. Please enter a valid TZ identifier." 10 80
    fi
done

dpr=$(whiptail --title "Nextcloud Default Phone Region" --inputbox "Nextcloud default phone region (Country code):" 10 80 "DE" 3>&1 1>&2 2>&3)
databasename=$(whiptail --title "SQL Database Name" --inputbox "SQL database name:" 10 80 "db$randomkey1" 3>&1 1>&2 2>&3)
databaseuser=$(whiptail --title "SQL Database User" --inputbox "SQL database user:" 10 80 "dbuser$randomkey1" 3>&1 1>&2 2>&3)
databaseuserpasswd=$(whiptail --title "SQL Database User Password" --inputbox "SQL database user password:" 10 80 "$randomkey2" 3>&1 1>&2 2>&3)
nextroot=$(whiptail --title "Nextcloud Admin Username" --inputbox "Nextcloud admin user name:" 10 80 "nextroot" 3>&1 1>&2 2>&3)
nextpass=$(whiptail --title "Nextcloud Admin Password" --inputbox "Nextcloud admin password:" 10 80 "$randomkey3" 3>&1 1>&2 2>&3)
ncdatafolder=$(whiptail --title "Nextcloud Data Folder" --inputbox "Nextcloud data folder:" 10 80 "/opt/nextcloud_data" 3>&1 1>&2 2>&3)



### self-signed  certificate
key_path="/etc/ssl/private/nc-selfsigned.key"
crt_path="/etc/ssl/certs/nc-selfsigned.crt"
subj="/C=DE/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=$ipv4network"
(
    for i in {1..100}; do
        sleep 0.1  # Adjust progress speed
        echo $i   # This simulates progress
    done
    openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -days 1800 -nodes \
    -keyout "$key_path" -out "$crt_path" -subj "$subj"
) | whiptail --gauge "Generating SSL Certificate..." 10 80 0
#openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=DE/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=$ipv4network"


### apache part
a2enmod ssl
a2enmod rewrite
a2enmod headers
systemctl stop apache2.service
mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak

cat << 'EOF' > /etc/apache2/ports.conf
Listen 89

<IfModule ssl_module>
        Listen $httpsport
</IfModule>

<IfModule mod_gnutls.c>
        Listen $httpsport
</IfModule>
EOF

cat << 'EOF' > /etc/apache2/sites-available/nc.conf
<VirtualHost *:$httpsport>
   ServerName $ipv4network
   DocumentRoot /var/www/nextcloud
   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/nc-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/nc-selfsigned.key

<Directory /var/www/nextcloud/>
  AllowOverride All
  Require host localhost
  Require ip $ipv4network2
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
cp /etc/php/8.4/apache2/php.ini /etc/php/8.4/apache2/php.ini.bak
sed -i "s/memory_limit = 128M/memory_limit = 1G/" /etc/php/8.4/apache2/php.ini
sed -i "s/output_buffering =.*/output_buffering = '0'/" /etc/php/8.4/apache2/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.4/apache2/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.4/apache2/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10G/" /etc/php/8.4/apache2/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10G/" /etc/php/8.4/apache2/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php/8.4/apache2/php.ini
sed -i "s/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/" /etc/php/8.4/apache2/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=256/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=64/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=100000/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/8.4/apache2/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/8.4/apache2/php.ini
sed -i "s/max_file_uploads =.*/max_file_uploads = 20/" /etc/php/8.4/apache2/php.ini

sed -i '$aopcache.jit=1255' /etc/php/8.4/apache2/php.ini
sed -i '$aopcache.jit_buffer_size=256M' /etc/php/8.4/apache2/php.ini

sed -i '$aapc.enable_cli=1' /etc/php/8.4/apache2/php.ini
sed -i '$aapc.enable_cli=1' /etc/php/8.4/mods-available/apcu.ini
sed -i '$aopcache.jit=1255' /etc/php/8.4/mods-available/opcache.ini
sed -i '$aopcache.jit_buffer_size=256M' /etc/php/8.4/mods-available/opcache.ini


sed -i '$a[mysql]' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.allow_local_infile=On' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.allow_persistent=On' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.cache_size=2000' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.max_persistent=-1' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.max_links=-1' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.default_port=3306' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.connect_timeout=60' /etc/php/8.4/mods-available/mysqli.ini
sed -i '$amysql.trace_mode=Off' /etc/php/8.4/mods-available/mysqli.ini


a2ensite nc.conf
systemctl start apache2.service


### DB part
systemctl start mariadb.service
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

whiptail --title "mariadb-secure-installation" --msgbox "Your database server will now be hardened - just follow the instructions.\nKeep in mind: your MariaDB root password is still NOT set !\nYou should set a root password, when asked\n" 15 90
mariadb-secure-installation
mariadb -uroot <<EOF
CREATE DATABASE $databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
GRANT ALL PRIVILEGES on $databasename.* to '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
FLUSH privileges;
EOF
systemctl restart mariadb.service


(crontab -l ; echo "*/5  *  *  *  * sudo -u www-data php -f /var/www/nextcloud/cron.php") | sort - | uniq - | crontab -

cat << 'EOF' >> /var/www/nextcloud/config/myextra.config.php
<?php
\$CONFIG = array (
   'memcache.local' => '\OC\Memcache\APCu',
   'memcache.locking' => '\OC\Memcache\Memcached',
   'default_phone_region' => '$dpr',
   'skeletondirectory' => '',
);
EOF

whiptail --title "nextcloud occ setup" --msgbox "Wait please, nextcloud occ setup is in progress after OK\n" 15 90
echo ""
echo "nextcloud occ setup running in background..... please wait....."

cd /var/www/nextcloud
sudo -u www-data php occ maintenance:install --database "mysql" --database-name "$databasename"  --database-user "$databaseuser" --database-pass "$databaseuserpasswd" --database-host "localhost:$dbport" --admin-user "$nextroot" --admin-pass "$nextpass" --data-dir "$ncdatafolder"
sudo -u www-data php occ config:system:set logtimezone --value="$ltz"
sudo -u www-data php occ config:system:set trusted_domains 1 --value=$ipv4network
sudo -u www-data php occ app:enable encryption
sudo -u www-data php occ encryption:enable
sudo -u www-data php occ encryption:encrypt-all
#sudo -u www-data php occ encryption:enable-master-key
# 2023.08 E2EE really not working as it should??? sudo -u www-data php occ app:enable end_to_end_encryption
sudo -u www-data php occ config:system:set maintenance_window_start --type=integer --value=1
sudo -u www-data php occ maintenance:repair --include-expensive
sudo -u www-data php occ db:add-missing-indices
sudo -u www-data php occ background:cron

systemctl start apache2.service


#whiptail --title "Info" --msgbox "E2EE end 2 end encryption is not working like usual without, functions too limited .......2023.08\nUsed serverside encryption for now, less secure but better than nothing .....\nA cloud VPS server is not really your host, its just someone else system,storage,and so on ......" 15 90

msgdata="Your settings, and passwords, maybe take a copy ....\n
Yes = Save this into /root/nextcloud.txt\n
No  = Just exit do not save in file\n
Your apache https port         :  $httpsport\n\
Your mariaDB port              :  $dbport\n\
SQL database name              :  $databasename\n\
SQL database user              :  $databaseuser\n\
SQL database user password     :  $databaseuserpasswd\n\
Your nextcloud data folder     :  $ncdatafolder\n\
Your nextcloud admin user      :  $nextroot\n\
Your nextcloud login password  :  $nextpass\n\
Now setup Nextcloud to your needs:  https://$ipv4network:$httpsport"


if whiptail --title "Settings Overview" --yesno "$msgdata" 80 80; then
cat << 'EOF' >> /root/nextcloud.txt
$msgdata
EOF
else
echo ""
fi  
