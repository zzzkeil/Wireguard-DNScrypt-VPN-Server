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

wg0portold=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
ufw delete allow $wg0portold/udp

systemctl stop wg-quick@wg0.service
rm -rv /etc/wireguard/*
 
tar -xvf /root/backup_wg_config.tar -C /

systemctl start wg-quick@wg0.service
wg0portnew=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
ufw allow proto udp to 0.0.0.0/0 port $wg0portnew

echo "."
echo "."
echo "."
echo " ok check your connection :) "
