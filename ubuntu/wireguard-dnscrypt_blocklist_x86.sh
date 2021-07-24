#!/bin/bash
clear
echo " ##############################################################################"
echo " # Wireguard-DNScrypt-VPN-Server setup script for Ubuntu 18.04 and above      #"
echo " # My base_setup script is needed to install, if not installed this script    #"
echo " # will automatically download the script, you need to run this manualy       #"
echo " # More information: https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server #"
echo " ##############################################################################"
echo " ##############################################################################"
echo " #                 Version 2021.07.24 - changelog on github                   #"
echo " ##############################################################################"
echo ""
echo ""
echo ""
echo "                     To EXIT this script press  [ENTER]"
echo ""
read -p "                     Press [Y] to begin" -n 1 -r
echo ""
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

### root check
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

### base_setup check
if [[ -e /root/base_setup.README ]]; then
     echo "base_setup script installed - OK"
	 else
	 wget -O  base_setup.sh https://raw.githubusercontent.com/zzzkeil/base_setups/master/base_setup.sh
         chmod +x base_setup.sh
	 echo ""
	 echo ""
	 echo " ERROR  - - one more thing to do "
	 echo " base_setup.sh script not installed!"
         echo " Now run ./base_setup.sh manualy and reboot, after that you can run this script again."
	 echo ""
	 echo ""
	 exit 1
fi

echo ""
echo ""

### check if Ubuntu OS 18.04 or 20.04
if [[ -e /etc/os-release ]]; then
      echo "/etc/os-release check = ok"
      else
      echo "/etc/os-release not found! Maybe no Ubuntu OS ?"
      echo " This script is made for Ubuntu 18.04 / 20.04"
      exit 1
fi

. /etc/os-release
if [[ "$NAME" = 'Ubuntu' ]]; then
   echo "OS Name check = ok"
   else 
   echo " This script is made for Ubuntu 18.04 / 20.04"
   exit 1
fi

if [[ "$VERSION_ID" = '18.04' ]] || [[ "$VERSION_ID" = '20.04' ]]; then
   echo "OS Versions check = ok"
   else
   echo "Ubuntu Versions below 18.04 not supported - upgrade please, its 2021 :) "
   exit 1
fi

if [[ "$VERSION_ID" = '18.04' ]]; then
    echo "Ubuntu Version = 18.04 - ppa:wireguard needed "
    add-apt-repository ppa:wireguard/wireguard
fi

if [[ "$VERSION_ID" = '20.04' ]]; then
    echo "Ubuntu Version = 20.04 - no ppa:wireguard needed "
fi

### script already installed check
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
     echo
	 echo
         echo "Looks like this script is already installed"
	 echo "This script is only need for the first install"
	 echo ""
	 echo "To add or remove clients run"
         echo " ./add_client.sh to add clients"
         echo " ./remove_client.sh to remove clients" 
	 echo ""
	 echo "To backup or restore your settings run"
	 echo " ./wg_config_backup.sh "
	 echo " ./wg_config_restore.sh"
	 echo ""
	 echo "For - News / Updates / Issues - check my github site"
	 echo "https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server"
	 echo
	 echo
	 exit 1
fi

### options
clear
echo ""
echo ""
echo " -- Your turn, make a decision -- "
echo ""
echo ""
echo ""
PS3='Choose 1 or 2 and press [ENTER] : '
options=("Use default ip´s and port settings" "Set your own ip´s and port settings")
select opt in "${options[@]}"
do
    case $opt in
        "Use the default ip´s and port settings")
           wg0port=51820
           wg0networkv4=66.66
           wg0networkv6=66:66:66
			break 
            ;;
        "Set your own ip´s and port settings")
           echo " Wireguard port settings :"
           echo "--------------------------------------------------------------------------------------------------------"
           read -p "Port: " -e -i 51820 wg0port
           echo "--------------------------------------------------------------------------------------------------------"
           echo "--------------------------------------------------------------------------------------------------------"
           echo " Wireguard ipv4 settings :"
           echo " Format prefix=10. suffix=.1 you set the middle Numbers like the following default example "
           echo " If you not familiar with ipv4 address scheme, do not change the defaults."
           echo "--------------------------------------------------------------------------------------------------------"
           echo "--------------------------------------------------------------------------------------------------------"
           read -p "clients ipv4 network: " -e -i 66.66 wg0networkv4
           echo "--------------------------------------------------------------------------------------------------------"
           echo " Wireguard ipv6 settings :"
           echo " Format prefix=fd42: suffix=::1 you set the middle Numbers like the following default example "
           echo " If you not familiar with ipv6 address scheme, do not change the defaults."
           echo "--------------------------------------------------------------------------------------------------------"
           echo "--------------------------------------------------------------------------------------------------------"
           read -p "clients ipv6 network: " -e -i 66:66:66 wg0networkv6
           echo "--------------------------------------------------------------------------------------------------------"
		   break 
            ;;
        *) 
	       echo ""
		   echo "ERROR - choose 1 or 2 : " 
		   echo "Try it again"
		   echo ""
		   ;;
    esac
done

clear
echo ""
echo ""


### apt systemupdate and installs	 
apt update && apt upgrade -y && apt autoremove -y
apt install qrencode unbound unbound-host python curl linux-headers-$(uname -r) -y 
apt install wireguard-dkms wireguard-tools -y

### create and download files for configs
echo "
+++ do not delete or modify this file +++
++ This file contains settings line by line ++

--- ip settings
ipv4 
$wg0networkv4
ipv6 
$wg0networkv6
--- port settings
wg0
$wg0port
---

For - News / Updates / Issues - check my github site
https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server
" > /root/Wireguard-DNScrypt-VPN-Server.README


curl -o add_client.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/add_client.sh
curl -o remove_client.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/remove_client.sh
curl -o wg_config_backup.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_backup.sh
curl -o wg_config_restore.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_restore.sh
curl -o uninstaller_back_to_base.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/uninstaller_back_to_base.sh
chmod +x add_client.sh
chmod +x remove_client.sh
chmod +x wg_config_backup.sh
chmod +x wg_config_restore.sh
chmod +x uninstaller_back_to_base.sh


### setup ufw and sysctl
inet=$(ip route show default | awk '/default/ {print $5}')
#ufw allow $wg0port/udp
ufw allow proto udp to 0.0.0.0/0 port $wg0port
cp /etc/default/ufw /root/script_backupfiles/ufw.orig
cp /etc/ufw/before.rules /root/script_backupfiles/before.rules.orig
cp /etc/ufw/before6.rules /root/script_backupfiles/before6.rules.orig
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n-A POSTROUTING -s 10.$wg0networkv4.0/24 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before.rules
sed -i "/# End required lines/a \\-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.$wg0networkv4.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.$wg0networkv4.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT" /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/a \\n# allow outbound icmp\n-A ufw-before-output -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT\n-A ufw-before-output -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT\n' /etc/ufw/before.rules
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n\n-A POSTROUTING -s fd42:$wg0networkv6::/112 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before6.rules
sed -i "/# End required lines/a \\-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:$wg0networkv6::1/64 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:$wg0networkv6::1/64 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT" /etc/ufw/before6.rules
cp /etc/sysctl.conf /root/script_backupfiles/sysctl.conf.orig
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
cp /etc/ufw/sysctl.conf /root/script_backupfiles/sysctl.conf.ufw.orig
sed -i 's@#net/ipv4/ip_forward=1@net/ipv4/ip_forward=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/default/forwarding=1@net/ipv6/conf/default/forwarding=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/all/forwarding=1@net/ipv6/conf/all/forwarding=1@g' /etc/ufw/sysctl.conf

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


echo "[Interface]
Address = 10.$wg0networkv4.1/24
Address = fd42:$wg0networkv6::1/112
ListenPort = $wg0port
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
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
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
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
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
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client3.conf
sed -i "s@CK03@$(cat /etc/wireguard/keys/client3)@" /etc/wireguard/client3.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client3.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client3.conf
chmod 600 /etc/wireguard/client3.conf


### setup unbound
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
curl -o /etc/unbound/unbound.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/configs/unbound.conf

sed -i "s/networkv4/$wg0networkv4/g" /etc/unbound/unbound.conf
sed -i "s/networkv6/$wg0networkv6/g" /etc/unbound/unbound.conf

chown -R unbound:unbound /var/lib/unbound

###setup DNSCrypt
mkdir /etc/dnscrypt-proxy/
wget -O /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.0.46-beta3/dnscrypt-proxy-linux_x86_64-2.0.46-beta3.tar.gz
tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
mv -f /etc/dnscrypt-proxy/linux-x86_64/* /etc/dnscrypt-proxy/
cp /etc/dnscrypt-proxy/example-blocked-names.txt /etc/dnscrypt-proxy/blocklist.txt 
curl -o /etc/dnscrypt-proxy/dnscrypt-proxy.toml https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/configs/dnscrypt-proxy.toml
curl -o /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/configs/dnscrypt-proxy-update.sh
chmod +x /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh

### setup blocklist and a allowlist from (anudeepND)"
mkdir /etc/dnscrypt-proxy/utils/
mkdir /etc/dnscrypt-proxy/utils/generate-domains-blocklists/
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/blocklist/domains-blocklist-default.conf
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist-local-additions.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-blocklist-local-additions.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-time-restricted.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-time-restricted.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-allowlist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
# old curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/generate-domains-blacklist.py
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/generate-domains-blocklist.py https://raw.githubusercontent.com/DNSCrypt/dnscrypt-proxy/master/utils/generate-domains-blocklist/generate-domains-blocklist.py
chmod +x /etc/dnscrypt-proxy/utils/generate-domains-blocklists/generate-domains-blocklist.py
cd /etc/dnscrypt-proxy/utils/generate-domains-blocklists/
nano /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-blocklist.conf
./generate-domains-blocklist.py > /etc/dnscrypt-proxy/blocklist.txt
cd
## check if generate blocklist failed - file is empty
curl -o /etc/dnscrypt-proxy/checkblocklist.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/configs/checkblocklist.sh
chmod +x /etc/dnscrypt-proxy/checkblocklist.sh

### create crontabs
(crontab -l ; echo "50 23 * * 4 cd /etc/dnscrypt-proxy/utils/generate-domains-blocklists/ &&  ./generate-domains-blocklist.py > /etc/dnscrypt-proxy/blocklists.txt") | sort - | uniq - | crontab -
(crontab -l ; echo "40 23 * * 4 curl -o /etc/dnscrypt-proxy/utils/generate-domains-blocklists/domains-allowlist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt") | sort - | uniq - | crontab -
(crontab -l ; echo "15 * * * 5 cd /etc/dnscrypt-proxy/ &&  ./etc/dnscrypt-proxy/checkblocklist.sh") | sort - | uniq - | crontab -
(crontab -l ; echo "59 23 * * 4,5 /bin/systemctl restart dnscrypt-proxy.service") | sort - | uniq - | crontab -
(crontab -l ; echo "59 23 * * 6 /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh") | sort - | uniq - | crontab -

### setup systemctl
systemctl stop systemd-resolved
systemctl disable systemd-resolved
cp /etc/resolv.conf /etc/resolv.conf.orig
rm -f /etc/resolv.conf
systemctl enable unbound
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
cp /etc/systemd/system/multi-user.target.wants/unbound.service /root/script_backupfiles/unbound.service.orig
curl -o /lib/systemd/system/unbound.service https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/configs/unbound.service
systemctl disable unbound
systemctl enable unbound
/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start
systemctl restart unbound

### finish
clear
echo ""
echo "QR Code for client1.conf "
qrencode -t ansiutf8 < /etc/wireguard/client1.conf
echo "Scan the QR Code with your Wiregard App"
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf
qrencode -o /etc/wireguard/client2.png < /etc/wireguard/client2.conf
qrencode -o /etc/wireguard/client3.png < /etc/wireguard/client3.conf
echo ""
echo " 2 extra client configs with QR Codes created in folder : /etc/wireguard/"
echo ""
echo " add or remove clients with ./add_client.sh or remove_client.sh"
echo ""
echo " backup and restore options with ./wg_config_backup.sh or ./wg_config_restore.sh"
echo ""
ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /etc/dnscrypt-proxy/ /root/dnscrypt-proxy_folder
ln -s /var/log /root/system-log_folder
ufw --force enable
ufw reload
