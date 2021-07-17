#!/bin/bash
clear
echo " this script restore yours wireguard server config "
echo " in case after you reinstalled your server with the same ip´s, ....."
echo " "
echo " work in progess "
echo "."
echo "."
echo "."
echo " this scrips delete your current files in /etc/wireguard/ "
eche " they will be replaced with the backupfiles "
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

systemctl stop wg-quick@wg0.service
rm -rv /etc/wireguard/*
 
tar -xvf /root/backup_wg_config.tar.gz -C /
systemctl start wg-quick@wg0.service
echo "."
echo "."
echo "."
echo " ok check your connection :) "
