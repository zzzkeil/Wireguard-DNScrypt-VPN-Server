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

### testing .... should run
if [[ "$ID" = 'rocky' ]]; then
 if [[ "$ROCKY_SUPPORT_PRODUCT" = 'Rocky-Linux-9' ]]; then
   echo -e "${GREEN}OS = Rocky Linux ${ENDCOLOR}"
   systemos=rocky
 fi
fi

### testing .... should run
if [[ "$ID" = 'almalinux' ]]; then
 if [[ "$ALMALINUX_MANTISBT_PROJECT" = 'AlmaLinux-9' ]]; then
   echo -e "${GREEN}OS = AlmaLinux ${ENDCOLOR}"
   systemos=almalinux
 fi
fi

### testing .... should run
if [[ "$ID" = 'centos' ]]; then
 if [[ "$VERSION_ID" = '9' ]]; then
   echo -e "${GREEN}OS = CentOS Stream ${ENDCOLOR}"
   systemos=centos
 fi
fi

if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 12, Fedora 38, Rocky Linux 9, CentOS Stream 9 !${ENDCOLOR}"
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


#
# OS updates
#
echo -e "${GREEN}update upgrade and install ${ENDCOLOR}"

if [[ "$systemos" = 'debian' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip
fi

if [[ "$systemos" = 'ubuntu' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install httpd mod_ssl libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip
fi

if [[ "$systemos" = 'rocky' ]] || [[ "$systemos" = 'centos' ]] || [[ "$systemos" = 'almalinux' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y

fi

##########################################################################
#notes
###########

a2enmod ssl
sudo openssl req -x509 -nodes -days 1825 -newkey rsa:4096 -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt

<VirtualHost 10.x.x.1:23443>
   ServerName 10.x.x.1
   DocumentRoot /var/www/nc-wireguard

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/nc-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/nc-selfsigned.key

<Directory /var/www/nc-wireguard/>
  Require host localhost
  Require ip 10
</Directory>

</VirtualHost>
>> /etc/apache2/sites-available/nc.conf

mkdir /var/www/nc-wireguard
a2ensite nc.conf
 

