#!/bin/bash
if whiptail --title "Remove wireguard client" --yesno "Remove a  wireguard client ?\n" 15 80; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, not right now. cu have a nice day." 15 80
exit 1
fi  

wgipcheck="/etc/wireguard/wg0.conf"
clients=$(grep "# Name = " "$wgipcheck" | awk '{print substr($0, 9)}')
menu_items=()
while read -r name; do
    menu_items+=("$name" "")
done <<< "$clients"
clientname=$(whiptail --title "Remove WireGuard Client" \
    --menu "Select a client to remove:" 20 60 10 \
    "${menu_items[@]}" \
    3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    whiptail --msgbox "Cancelled by user." 8 40
    exit 1
fi

rm /etc/wireguard/keys/$clientname
rm /etc/wireguard/keys/$clientname.pub
rm /etc/wireguard/$clientname.conf
rm /etc/wireguard/$clientname.png
sed -i "/# Name = $clientname/,+3 d" /etc/wireguard/wg0.conf
systemctl restart wg-quick@wg0.service
whiptail --title "Finish" --msgbox "Client $clientname deleted, wireguard restarted" 15 80
exit 1
