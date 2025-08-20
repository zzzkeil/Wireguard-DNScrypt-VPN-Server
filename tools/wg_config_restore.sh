#!/bin/bash
if whiptail --title "Restore wireguard config" --yesno "This script restores your wireguard server config, \nafter you reinstalled your server with the same ip´s,...\n\nmake sure your backupfile is here : /root/backup_wg_config.tar\n\nThis scrips delete your current files in /etc/wireguard/ \n\nRun script now ?\n" 15 80; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, not now. cu have a nice day." 15 80
exit 0
fi  
if [[ -e /root/backup_wg_config.tar ]]; then
    whiptail --title "Backup found" --msgbox "Backupfile found:  /root/backup_wg_config.tar.gz" 15 80
	 else
	 whiptail --title "Backup not found" --msgbox "Backupfile not found in:  /root/backup_wg_config.tar.gz\nAborted" 15 80
	 exit 1
fi

systemctl stop wg-quick@wg0.service
### remove existing firewalld rules from setup
oldhostipv4=$(hostname -I | awk '{print $1}')
oldhostipv6=$(hostname -I | awk '{print $2}')
oldwg0networkv4=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
oldwg0networkv42="${oldwg0networkv4%.*}.0"
oldwg0networkv6=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
oldwg0networkv62="${oldwg0networkv6%:*}:"
oldwg0port=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
firewall-cmd --zone=public --remove-port="$oldwg0port"/udp

firewall-cmd --zone=trusted --remove-source=$oldwg0networkv42/24
firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s $oldwg0networkv42/24 ! -d $oldwg0networkv42/24 -j SNAT --to "$oldhostipv4"

if [[ -n "$oldhostipv6" ]]; then
firewall-cmd --zone=trusted --remove-source=$oldwg0networkv62/64
firewall-cmd --direct --add-remove ipv6 nat POSTROUTING 0 -s $oldwg0networkv62/64 ! -d $oldwg0networkv62/64 -j SNAT --to "$oldhostipv6"
fi

rm -rv /etc/wireguard/*
rm /root/Wireguard-DNScrypt-VPN-Server.README

### unpack backupfile
tar -xvf /root/backup_wg_config.tar -C /

### restore firewalld rules from backup
hostipv4=$(hostname -I | awk '{print $1}')
hostipv6=$(hostname -I | awk '{print $2}')
wg0networkv4=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0networkv42="${wg0networkv4%.*}.0"
wg0networkv6=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0networkv62="${wg0networkv6%:*}:"
wg0port=$(sed -n 12p /root/Wireguard-DNScrypt-VPN-Server.README)
firewall-cmd --zone=public --add-port="$wg0port"/udp

firewall-cmd --zone=trusted --add-source=$wg0networkv42/24
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s $wg0networkv42/24 ! -d $wg0networkv42/24 -j SNAT --to "$hostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --add-source=$wg0networkv62::/64
firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s $wg0networkv62/64 ! -d $wg0networkv62/64 -j SNAT --to "$hostipv6"
fi
firewall-cmd --runtime-to-permanent

systemctl start wg-quick@wg0.service
whiptail --title "Done" --msgbox "ok check your connection :)" 15 80
exit 0
