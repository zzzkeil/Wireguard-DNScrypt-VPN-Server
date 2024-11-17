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
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo ""
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN} Test Version 2024.11.xx - ------   ${ENDCOLOR}"
echo ""
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}Wireguard-DNScrypt-Server setup for Debian 12 ${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}My base_setup.sh script is needed to setup this script correctly!!${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}If not installed, a automatic download starts, then follow the instructions${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}More info: https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server${ENDCOLOR}"
echo ""
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
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

if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 12 !${ENDCOLOR}"
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


### base_setup check
if [[ -e /root/base_setup.README ]]; then
     echo -e "base_setup script installed = ${GREEN}ok${ENDCOLOR}"
	 else
	 echo -e " ${YELLOW}Warning:${ENDCOLOR}"
	 echo -e " ${YELLOW}You need to install my base_setup script first!${ENDCOLOR}"
	 echo -e " ${YELLOW}Starting download base_setup.sh from my repository${ENDCOLOR}"
	 echo ""
	 echo ""
	 wget -O  base_setup.sh https://raw.githubusercontent.com/zzzkeil/base_setups/refs/heads/master/thesamebutnew.sh
         chmod +x base_setup.sh
	 echo ""
	 echo ""
         echo -e " Now run ${YELLOW}./base_setup.sh${ENDCOLOR} manualy and reboot, then run this script again."
	 echo ""
	 echo ""
	 exit 1
fi


### script already installed check
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
     echo
	 echo
         echo -e "${YELLOW}Looks like this script is already installed${ENDCOLOR}"
	 echo -e "${YELLOW}This script is only need for the first install${ENDCOLOR}"
	 echo ""
	 echo "To add or remove clients run"
         echo -e " ${YELLOW}./add_client.sh${ENDCOLOR} to add clients"
         echo -e " ${YELLOW}./remove_client.sh${ENDCOLOR} to remove clients"
	 echo ""
	 echo  "To backup or restore your settings run"
	 echo -e " ${YELLOW}./wg_config_backup.sh${ENDCOLOR} "
	 echo -e " ${YELLOW}./wg_config_restore.sh${ENDCOLOR}"
	 echo ""
	 echo  "To uninstall run"
	 echo -e " ${RED}./uninstaller_back_to_base.sh${ENDCOLOR} "
	 echo ""
	 echo "For - News / Updates / Issues - check my github site"
	 echo "https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server"
	 echo
	 echo
	 exit 1
fi


### options
echo ""
echo ""
echo -e " -- Your turn, make a decision -- "
echo ""
echo ""
echo ""
echo -e "${GREEN}Press any key for default port and ip and settings ${ENDCOLOR}"
echo "or"
echo -e "${RED}Press [Y] to change default port; ip; MTU; keepalive (advanced user)${ENDCOLOR}"
echo ""
read -p "" -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
wg0port=51820
wg0networkv4=66.66
wg0networkv6=66:66:66
wg0servermtu="#MTU = 1420"
wg0mtu="#MTU = 1420"
wg0keepalive="#PersistentKeepalive = 25"
else
echo ""
echo " Wireguard port settings :"
echo "--------------------------------------------------------------------------------------------------------"
read -p "Port: " -e -i 51820 wg0port
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
#echo " Wireguard ${GREEN} SERVER ${ENDCOLOR} MTU settings :"
#echo -e " If you not familiar with MTU settings, change to the default value ${GREEN} 1420 ${ENDCOLOR} and press [ENTER]."
#echo "--------------------------------------------------------------------------------------------------------"
#echo "--------------------------------------------------------------------------------------------------------"
#read -p "MTU =  " -e -i 1420 wg0servermtu
#echo "--------------------------------------------------------------------------------------------------------"
#echo "--------------------------------------------------------------------------------------------------------"
echo " Wireguard ipv4 settings :"
echo -e " Format prefix=10. suffix=.1 you can change the green value. eg. 10.${GREEN}66.66${ENDCOLOR}.1"
echo " If you not familiar with ipv4 address scheme, do not change the defaults and press [ENTER]."
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "clients ipv4 network: " -e -i 66.66 wg0networkv4
echo "--------------------------------------------------------------------------------------------------------"
echo " Wireguard ipv6 settings :"
echo -e " Format prefix=fd42: suffix=::1 you can change the green value. eg. fd42:${GREEN}66:66:66${ENDCOLOR}::1"
echo " If you not familiar with ipv6 address scheme, do not change the defaults and press [ENTER]."
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "clients ipv6 network: " -e -i 66:66:66 wg0networkv6
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
echo -e " Wireguard ${GREEN} CLIENTS ${ENDCOLOR} MTU settings :"
echo -e " If you not familiar with MTU settings, change to the default value ${GREEN} 1420 ${ENDCOLOR} and press [ENTER]."
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "MTU =  " -e -i 1380 wg0mtu02
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
echo " Wireguard keepalive settings :"
echo -e " If you not familiar with keepalive settings, do not change the defaults and press [ENTER] ${GREEN}[default = 0]${ENDCOLOR}."
echo "--------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
read -p "PersistentKeepalive =  : " -e -i 0 wg0keepalive02
echo "--------------------------------------------------------------------------------------------------------"
wg0mtu="MTU = $wg0mtu02"
wg0keepalive="PersistentKeepalive = $wg0keepalive02"

fi
### AllowedIPs options - local ips in testing... maybe not a perfect solution !!!
echo " -- AllowedIPs handling for the first 3 preset client configs -- "
echo "--------------------------------------------------------------------------------------------------------"
echo -e "${GREEN}Press any key to tunnel all trafic over wireguard ${ENDCOLOR}"
echo "or"
echo -e "${RED}Press [A] to exclude local ips > Class A: 10. Class B: 172.16. Class C: 192.168. (advanced user)${ENDCOLOR}"
echo "--------------------------------------------------------------------------------------------------------"
echo ""
read -p "" -n 1 -r
if [[ ! $REPLY =~ ^[Aa]$ ]]
then
allownet="0.0.0.0/0, ::/0"
else
allownet="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, 10.$ipv4network.0/24, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, fd42:$ipv6network::/64, fe00::/9, fec0::/10, ff00::/8"
fi

clear
echo ""

#
# OS updates
#
echo -e "${GREEN}update upgrade and install ${ENDCOLOR}"

if [[ "$systemos" = 'debian' ]] || [[ "$systemos" = 'ubuntu' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install qrencode python-is-python3 curl linux-headers-$(uname -r) -y
apt install wireguard wireguard-tools -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install qrencode python-is-python3 curl cronie cronie-anacron -y
dnf install wireguard-tools -y
fi

if [[ "$systemos" = 'rocky' ]] || [[ "$systemos" = 'centos' ]] || [[ "$systemos" = 'almalinux' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install qrencode curl cronie cronie-anacron -y
dnf install wireguard-tools -y
fi

### create and download files for configs  wg0servermtu später noch einpflegen 
echo "
!!! do not delete or modify this file
!!  This file contains values line by line, used for config, backups and restores

--- ip settings
ipv4
$wg0networkv4
ipv6
$wg0networkv6
--- port and misc settings
wg0
$wg0port
$wg0mtu
$wg0keepalive
---

For - News / Updates / Issues - check my gitlab site
https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server
" > /root/Wireguard-DNScrypt-VPN-Server.README


curl -o add_client.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/add_client.sh
curl -o remove_client.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/remove_client.sh
curl -o wg_config_backup.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_backup.sh
curl -o wg_config_restore.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_restore.sh
curl -o uninstaller_back_to_base.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/uninstaller_back_to_base.sh
curl -o nextcloud-behind-wireguard.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/refs/heads/master/nextcloud-behind-wireguard.sh

chmod +x add_client.sh
chmod +x remove_client.sh
chmod +x wg_config_backup.sh
chmod +x wg_config_restore.sh
chmod +x uninstaller_back_to_base.sh
chmod +x nextcloud-behind-wireguard.sh


firewalldstatus="$(systemctl is-active firewalld)"
if [ "${firewalldstatus}" = "active" ]; then
echo "ok firewalld is running"
else 
systemctl restart firewalld  
fi

### setup firewalld and sysctl
hostipv4=$(hostname -I | awk '{print $1}')
hostipv6=$(hostname -I | awk '{print $2}')

firewall-cmd --zone=public --add-port="$wg0port"/udp

firewall-cmd --zone=trusted --add-source=10.$wg0networkv4.0/24
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.$wg0networkv4.0/24 ! -d 10.$wg0networkv4.0/24 -j SNAT --to "$hostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --add-source=fd42:$wg0networkv6::/64
firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s fd42:$wg0networkv6::/64 ! -d fd42:$wg0networkv6::/64 -j SNAT --to "$hostipv6"
fi

# wrong....
#firewall-cmd --zone=trusted --add-forward-port=port=53:proto=tcp:toport=53:toaddr=127.0.0.1
#firewall-cmd --zone=trusted --add-forward-port=port=53:proto=udp:toport=53:toaddr=127.0.0.1

firewall-cmd --runtime-to-permanent

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard_ip_forward.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/99-wireguard_ip_forward.conf

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

### setup wireguard keys and configs
mkdir /etc/wireguard/keys
chmod 700 /etc/wireguard/keys

touch /etc/wireguard/keys/server0
chmod 600 /etc/wireguard/keys/server0
wg genkey > /etc/wireguard/keys/server0
wg pubkey < /etc/wireguard/keys/server0 > /etc/wireguard/keys/server0.pub

touch /etc/wireguard/keys/client1
chmod 600 /etc/wireguard/keys/client1
wg genkey > /etc/wireguard/keys/client1
wg pubkey < /etc/wireguard/keys/client1 > /etc/wireguard/keys/client1.pub

touch /etc/wireguard/keys/client2
chmod 600 /etc/wireguard/keys/client2
wg genkey > /etc/wireguard/keys/client2
wg pubkey < /etc/wireguard/keys/client2 > /etc/wireguard/keys/client2.pub

touch /etc/wireguard/keys/client3
chmod 600 /etc/wireguard/keys/client3
wg genkey > /etc/wireguard/keys/client3
wg pubkey < /etc/wireguard/keys/client3 > /etc/wireguard/keys/client3.pub

##set AllowedIPs to execlute local ips > Class A: 10. Class B: 172.16. Class C: 192.168.
allownet="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, 10.$wg0networkv4.0/24, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, fd42:$wg0networkv6::/64, fe00::/9, fec0::/10, ff00::/8"

echo "[Interface]
Address = 10.$wg0networkv4.1/24
Address = fd42:$wg0networkv6::1/112
ListenPort = $wg0port
#MTU = $wg0servermtu$wg0networkv4
PrivateKey = SK01


# client1
[Peer]
PublicKey = PK01
AllowedIPs = 10.$wg0networkv4.11/32, fd42:$wg0networkv6::11/128
# client2
[Peer]
PublicKey = PK02
AllowedIPs = 10.$wg0networkv4.12/32, fd42:$wg0networkv6::12/128
# client3
[Peer]
PublicKey = PK03
AllowedIPs = 10.$wg0networkv4.13/32, fd42:$wg0networkv6::13/128
# -end of default clients

" > /etc/wireguard/wg0.conf

sed -i "s@SK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/client1.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK02@$(cat /etc/wireguard/keys/client2.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK03@$(cat /etc/wireguard/keys/client3.pub)@" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf

echo "[Interface]
Address = 10.$wg0networkv4.11/32
Address = fd42:$wg0networkv6::11/128
PrivateKey = CK01
DNS = 10.$wg0networkv4.1, fd42:$wg0networkv6::1
$wg0mtu
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
$wg0keepalive
" > /etc/wireguard/client1.conf
sed -i "s@CK01@$(cat /etc/wireguard/keys/client1)@" /etc/wireguard/client1.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client1.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client1.conf
chmod 600 /etc/wireguard/client1.conf

echo "[Interface]
Address = 10.$wg0networkv4.12/32
Address = fd42:$wg0networkv6::12/128
PrivateKey = CK02
DNS = 10.$wg0networkv4.1, fd42:$wg0networkv6::1
$wg0mtu
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
$wg0keepalive
" > /etc/wireguard/client2.conf
sed -i "s@CK02@$(cat /etc/wireguard/keys/client2)@" /etc/wireguard/client2.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client2.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client2.conf
chmod 600 /etc/wireguard/client2.conf

echo "[Interface]
Address = 10.$wg0networkv4.13/32
Address = fd42:$wg0networkv6::13/128
PrivateKey = CK03
DNS = 10.$wg0networkv4.1, fd42:$wg0networkv6::1
$wg0mtu
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
$wg0keepalive
" > /etc/wireguard/client3.conf
sed -i "s@CK03@$(cat /etc/wireguard/keys/client3)@" /etc/wireguard/client3.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client3.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client3.conf
chmod 600 /etc/wireguard/client3.conf


###setup DNSCrypt
mkdir /etc/dnscrypt-proxy/
wget -O /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_$dnsscrpt_arch-2.1.5.tar.gz
tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
mv -f /etc/dnscrypt-proxy/linux-$dnsscrpt_arch/* /etc/dnscrypt-proxy/
cp /etc/dnscrypt-proxy/example-blocked-names.txt /etc/dnscrypt-proxy/blocklist.txt
curl -o /etc/dnscrypt-proxy/dnscrypt-proxy.toml https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/dnscrypt-proxy.toml
curl -o /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/dnscrypt-proxy-update.sh
chmod +x /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh

### setup blocklist (url & ips) and a allowlist from (anudeepND)"
mkdir /etc/dnscrypt-proxy/utils/
mkdir /etc/dnscrypt-proxy/utils/generate-domains-blocklists/
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/domains-blocklist-default.conf
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist-local-additions.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-blocklist-local-additions.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-time-restricted.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-time-restricted.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-allowlist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/generate-domains-blocklist.py https://raw.githubusercontent.com/DNSCrypt/dnscrypt-proxy/master/utils/generate-domains-blocklist/generate-domains-blocklist.py
chmod +x /etc/dnscrypt-proxy/utils/generate-domains-blocklists/generate-domains-blocklist.py
cd /etc/dnscrypt-proxy/utils/generate-domains-blocklists/
nano /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist.conf
./generate-domains-blocklist.py > /etc/dnscrypt-proxy/blocklist.txt
cd
### setup your allowlist
curl -o /etc/dnscrypt-proxy/allowed-names.txt https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/domains-allowed-names.txt
nano /etc/dnscrypt-proxy/allowed-names.txt
## check if generate blocklist failed - file is empty
curl -o /etc/dnscrypt-proxy/checkblocklist.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/checkblocklist.sh
chmod +x /etc/dnscrypt-proxy/checkblocklist.sh

curl -o /etc/dnscrypt-proxy/blockedlist-ips.txt https://iplists.firehol.org/files/yoyo_adservers.ipset

### create crontabs
(crontab -l ; echo "50 23 * * 4 cd /etc/dnscrypt-proxy/utils/generate-domains-blocklists/ &&  ./generate-domains-blocklist.py > /etc/dnscrypt-proxy/blocklist.txt") | sort - | uniq - | crontab -
(crontab -l ; echo "30 23 * * 4 curl -o /etc/dnscrypt-proxy/blockedlist-ips.txt https://iplists.firehol.org/files/yoyo_adservers.ipset") | sort - | uniq - | crontab -
(crontab -l ; echo "40 23 * * 4 curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-allowlist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt") | sort - | uniq - | crontab -
(crontab -l ; echo "15 * * * 5 cd /etc/dnscrypt-proxy/ &&  ./etc/dnscrypt-proxy/checkblocklist.sh") | sort - | uniq - | crontab -
(crontab -l ; echo "59 23 * * 4,5 /bin/systemctl restart dnscrypt-proxy.service") | sort - | uniq - | crontab -
(crontab -l ; echo "59 23 * * 6 /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh") | sort - | uniq - | crontab -

### setup systemctl
systemctl stop systemd-resolved
systemctl disable systemd-resolved
cp /etc/resolv.conf /etc/resolv.conf.orig
rm -f /etc/resolv.conf
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start


### finish
echo ""
echo ""
echo -e "${YELLOW}QR Code for client1.conf${ENDCOLOR}"
echo ""
qrencode -t ansiutf8 < /etc/wireguard/client1.conf
echo ""
echo -e "${YELLOW}Scan the QR Code with your Wiregard App${ENDCOLOR}"
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf
qrencode -o /etc/wireguard/client2.png < /etc/wireguard/client2.conf
qrencode -o /etc/wireguard/client3.png < /etc/wireguard/client3.conf
echo ""
echo " 2 extra client configs with QR Codes created in folder : /etc/wireguard/"
echo ""
echo -e " add or remove clients with ${YELLOW}./add_client.sh / remove_client.sh${ENDCOLOR}"
echo ""
echo -e " backup and restore options with ${YELLOW}./wg_config_backup.sh / ./wg_config_restore.sh${ENDCOLOR}"
echo ""
echo ""
echo ""
echo " Now it takes a time befor dnscrypt-proxy is ready. You can check the logfile with : cat /var/log/dnscrypt-proxy.log "
echo ""
echo ""
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}Need a nextcloud instance behind wireguard ? - run ./nextcloud-behind-wireguard.sh ${ENDCOLOR}"
echo -e " ${GRAYB}#${ENDCOLOR} ${GREEN}You can only connect to this nextcloud, if you have wireguard on ......  ${ENDCOLOR}"
echo -e " ${GRAYB}#######################################################################################################################################${ENDCOLOR}"

ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /etc/dnscrypt-proxy/ /root/dnscrypt-proxy_folder
ln -s /var/log /root/system-log_folder

systemctl restart firewalld
exit
