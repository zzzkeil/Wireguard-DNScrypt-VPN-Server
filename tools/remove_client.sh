#!/bin/bash
clear
echo " Just 4 testing now "
echo " maybe dont work "
echo " be carefull"
echo "."
echo "."
echo "."
echo "."
###
echo "Client Name to remove"
echo "Choose the # clientname above the line [Peer] in wg0.conf"
echo "for example: to remove one of the default clients type: client11"
read -p "client name: " -e -i removeclient clientname
echo "------"

rm /etc/wireguard/keys/$clientname
rm /etc/wireguard/keys/$clientname.pub
rm /etc/wireguard/$clientname.conf
rm /etc/wireguard/$clientname.png
sed -i "/# $clientname/,+3 d" /etc/wireguard/wg0.conf
systemctl restart wg-quick@wg0.service
echo "Client $clientname removed, wireguard restarted"
