#!/bin/bash
clear
echo " To remove a client follow this steps"
echo "."
echo "."
echo "."
echo "."
###
echo "Client Name to remove"
echo "List clients:"
echo ""
grep "# Name = " /etc/wireguard/wg0.conf | awk '{print substr($0, 9)}'
echo ""
echo ""
echo "Type clientname you want to remove"
echo "Example: to remove client5 type client5"
while true; do
    read -p "Client name: " -e -i "$clientname" clientname
    if [[ -n "$clientname" ]]; then
        break
    else
        echo "Client name cannot be empty. Please enter a valid name."
    fi
done

echo "------"

rm /etc/wireguard/keys/$clientname
rm /etc/wireguard/keys/$clientname.pub
rm /etc/wireguard/$clientname.conf
rm /etc/wireguard/$clientname.png
sed -i "/# Name = $clientname/,+3 d" /etc/wireguard/wg0.conf
systemctl restart wg-quick@wg0.service
echo "Client $clientname deleted if it existed, wireguard restarted"
