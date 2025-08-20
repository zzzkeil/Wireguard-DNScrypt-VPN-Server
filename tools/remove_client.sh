#!/bin/bash
if whiptail --title "Remove wireguard client" --yesno "Remove a new wireguard client ?\n" 15 80; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, not right now. cu have a nice day." 15 80
exit 1
fi  

wgipcheck="/etc/wireguard/wg0.conf"
client_list=$(grep "# Name = " "$wgipcheck" | awk '{print substr($0, 9)}')

whiptail --title "Remove WireGuard Client" --msgbox "List of existing clients:\n\n$client_list\n\n" 20 60
while true; do
    clientname=$(whiptail --inputbox "Enter the name of the client to remove:" 10 60 "$clientname" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        whiptail --msgbox "Cancelled by user." 8 40
        exit 1
    fi
    if [[ -z "$clientname" ]]; then
        whiptail --msgbox "Client name cannot be empty. Please try again." 8 50
    else
        break
    fi
done
rm /etc/wireguard/keys/$clientname
rm /etc/wireguard/keys/$clientname.pub
rm /etc/wireguard/$clientname.conf
rm /etc/wireguard/$clientname.png
sed -i "/# Name = $clientname/,+3 d" /etc/wireguard/wg0.conf
systemctl restart wg-quick@wg0.service
echo "Client $clientname deleted if it existed, wireguard restarted"
