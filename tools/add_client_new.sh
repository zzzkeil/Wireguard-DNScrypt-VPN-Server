#!/bin/bash
if whiptail --title "New wireguard client" --yesno "Create a new wg client ?\n" 15 80; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, not right now. cu have a nice day." 15 80
exit 1
fi  

ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv4network2="${ipv4network%.*}."
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv6network2="${ipv6network%:*}:"
wg0port=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')
wgipcheck="/etc/wireguard/wg0.conf"

if whiptail --title "Client traffic over wireguard" --yesno "Yes =  Tunnel all traffic over wireguard\n       0.0.0.0/0, ::/0\n\nNo  =  Exclude private network ip's\n       10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 not over wireguard\n" 15 80; then
allownet="0.0.0.0/0, ::/0"
else
allownet="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, $ipv4network/24, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, $ipv6network/64, fe00::/9, fec0::/10, ff00::/8"
fi  


while true; do
    clientname=$(whiptail --inputbox "Enter a clientname (no spaces allowed):" 10 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        echo "User cancelled input."
        exit 1
    fi
    if [[ -z "$clientname" ]]; then
        whiptail --msgbox "Name cannot be empty!" 8 40
    elif [[ "$clientname" == *" "* ]]; then
        whiptail --msgbox "Spaces are not allowed!" 8 40
    else
        break
    fi
done


while true; do
    ipv4end=$(whiptail --inputbox "Enter a number between 11 and 254:" 10 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        whiptail --msgbox "User cancelled input. Exiting..." 8 50
        exit 1
    fi
    if [[ ! "$ipv4end" =~ ^[0-9]+$ ]]; then
        whiptail --msgbox "Invalid input! Please enter numbers only." 8 50
    elif [ "$ipv4end" -lt 11 ] || [ "$ipv4end" -gt 254 ]; then
        whiptail --msgbox "Number must be between 11 and 254." 8 50
    else
        checkipv4="${ipv4network2}${ipv4end}"
        
        if grep -q "$checkipv4" "$wgipcheck"; then
            whiptail --msgbox "The IP $checkipv4 already exists.\n\nRun the script again and choose a different number." 10 60
            exit 1
        else
            break
        fi
    fi
done

while true; do
    ipv6end=$(whiptail --inputbox "Enter a number between 11 and 254:" 10 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        whiptail --msgbox "User cancelled input. Exiting..." 8 50
        exit 1
    fi
    if [[ ! "$ipv6end" =~ ^[0-9]+$ ]]; then
        whiptail --msgbox "Invalid input! Please enter numbers only." 8 50
    elif [ "$ipv6end" -lt 11 ] || [ "$ipv6end" -gt 254 ]; then
        whiptail --msgbox "Number must be between 11 and 254." 8 50
    else
        checkipv6="${ipv6network2}${ipv6end}"
        
        if grep -q "$checkipv6" "$wgipcheck"; then
            whiptail --msgbox "The IP $checkipv6 already exists.\n\nRun the script again and choose a different number." 10 60
            exit 1
        else
            break
        fi
    fi
done

### server side config
touch /etc/wireguard/keys/$clientname
chmod 600 /etc/wireguard/keys/$clientname
wg genkey > /etc/wireguard/keys/$clientname
wg pubkey < /etc/wireguard/keys/$clientname > /etc/wireguard/keys/$clientname.pub

echo "
# Name = $clientname
[Peer]
PublicKey = NEWPK
AllowedIPs = $checkipv4/32, $checkipv6/128
" >> /etc/wireguard/wg0.conf
sed -i "s@NEWPK@$(cat /etc/wireguard/keys/$clientname.pub)@" /etc/wireguard/wg0.conf

### client side config
echo "[Interface]
Address = $checkipv4/32
Address = $checkipv6/128
PrivateKey = NEWCLKEY
DNS = $ipv4network, $ipv6network
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
" > /etc/wireguard/$clientname.conf
sed -i "s@NEWCLKEY@$(cat /etc/wireguard/keys/$clientname)@" /etc/wireguard/$clientname.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/$clientname.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/$clientname.conf
chmod 600 /etc/wireguard/$clientname.conf

echo "QR Code for $clientname.conf "
qrencode -t ansiutf8 < /etc/wireguard/$clientname.conf
echo "Scan the QR Code with your Wiregard App"
qrencode -o /etc/wireguard/$clientname.png < /etc/wireguard/$clientname.conf
echo "saved $clientname.conf and QR Code file in folder : /etc/wireguard/"
echo ""
systemctl restart wg-quick@wg0.service
