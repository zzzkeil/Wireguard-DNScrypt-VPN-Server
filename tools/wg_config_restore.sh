#!/bin/bash
clear
echo " this script restore yours wireguard server config "
echo " in case after you reinstalled your server with the same ip´s, ....."
echo "."
echo "."
echo "."
echo " make sure your backupfile is here : /root/backup_wg_config.tar "
echo " ! ! this scrips delete your current files in /etc/wireguard/ ! ! "
echo " they will be replaced with the backupfiles "
echo "."
echo "."
echo "."
echo "To EXIT this script press  [ENTER]"
echo 
read -p "To RUN this script press  [Y]" -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [[ -e /root/backup_wg_config.tar ]]; then
     echo "backupfile found. ok lets go"
	 else
	 echo " !! No backupfile found !!"
	 echo " Make sure you have placed your backupfile in:"
         echo " /root/backup_wg_config.tar "
	 echo ""
	 echo ""
	 exit 1
fi


### remove existing firewalld rules from setup
oldhostipv4=$(hostname -I | awk '{print $1}')
oldhostipv6=$(hostname -I | awk '{print $2}')
oldipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
oldipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
oldwg0port=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
firewall-cmd --zone=public --remove-port="$oldwg0port"/udp

firewall-cmd --zone=trusted --remove-source=10.$oldwg0networkv4.0/24
firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.$oldwg0networkv4.0/24 ! -d 10.$oldwg0networkv4.0/24 -j SNAT --to "$oldhostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --remove-source=fd42:$oldwg0networkv6::/64
firewall-cmd --direct --add-remove ipv6 nat POSTROUTING 0 -s fd42:$oldwg0networkv6::/64 ! -d fd42:$oldwg0networkv6::/64 -j SNAT --to "$oldhostipv6"
fi

systemctl stop wg-quick@wg0.service
rm -rv /etc/wireguard/*
rm /root/Wireguard-DNScrypt-VPN-Server.README



### unpack backupfile
tar -xvf /root/backup_wg_config.tar -C /

### restore firewalld rules from backup
hostipv4=$(hostname -I | awk '{print $1}')
hostipv6=$(hostname -I | awk '{print $2}')
ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0port=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
firewall-cmd --zone=public --add-port="$wg0port"/udp

firewall-cmd --zone=trusted --add-source=10.$wg0networkv4.0/24
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.$wg0networkv4.0/24 ! -d 10.$wg0networkv4.0/24 -j SNAT --to "$hostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --add-source=fd42:$wg0networkv6::/64
firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s fd42:$wg0networkv6::/64 ! -d fd42:$wg0networkv6::/64 -j SNAT --to "$hostipv6"
fi
firewall-cmd --runtime-to-permanent

systemctl start wg-quick@wg0.service
echo "."
echo "."
echo "."
echo " ok check your connection :) "
