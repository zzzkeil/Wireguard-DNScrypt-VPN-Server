#!/bin/bash
clear
echo " To remove a client follow this steps"
echo "."
echo "."
echo "."
echo "."
###
echo "Client Name to remove"
echo "List Names"
grep "# Name = " /etc/wireguard/wg0.conf | awk '{print substr($0, 9)}'
echo "Type clientname you want to remove"
echo "for example: to remove client5 type client5"
read -p "client name: " -e -i client5 clientname
echo "------"

rm /etc/wireguard/keys/$clientname
rm /etc/wireguard/keys/$clientname.pub
rm /etc/wireguard/$clientname.conf
rm /etc/wireguard/$clientname.png
sed -i "/# Name = $clientname/,+3 d" /etc/wireguard/wg0.conf
systemctl restart wg-quick@wg0.service
echo "Client $clientname removed, wireguard restarted"
