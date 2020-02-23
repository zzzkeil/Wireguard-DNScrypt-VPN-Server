#!/bin/bash
clear
echo " Just 4 testing now "
echo " maybe dont work "
echo " be careful"
echo "."
echo "."
echo "."
echo "."
###
echo "Client Name"
echo "don´use a clientname from client1 to client11 !"
echo "these clientnames exsist/reserved by the setupscript!"
read -p "client name: " -e -i newclient clientname
echo "------"
echo "Client IPv4"
echo "don´use a ipv4 address under 10.8.0.30 and in this /24 subnet!"
echo "these ipv4 exsist/reserved by the setupscript!"
read -p "client IPv4: " -e -i 10.8.0.30 clientipv4
echo "------"
echo "Client IPv6"
echo "don´use a ipv4 address under fd42:42:42:42::30 and in this /64 subnet!"
echo "these ipv4 exsist/reserved by the setupscript!"
read -p "client IPv6: " -e -i fd42:42:42:42::30 clientipv6
echo "------"
echo "Your Wireguard port"
echo "set your wireguard port from the line below:"
grep ListenPort /etc/wireguard/wg0.conf 
read -p "Wireguard port: " -e -i  0 wg0port


### server side config
touch /etc/wireguard/keys/$clientname
chmod 600 /etc/wireguard/keys/$clientname
wg genkey > /etc/wireguard/keys/$clientname
wg pubkey < /etc/wireguard/keys/$clientname > /etc/wireguard/keys/$clientname.pub

echo "
# $clientname
[Peer]
PublicKey = NEWPK
AllowedIPs = $clientipv4/32, $clientipv6/128
" >> /etc/wireguard/wg0.conf
sed -i "s@NEWPK@$(cat /etc/wireguard/keys/$clientname.pub)@" /etc/wireguard/wg0.conf

### client side config
echo "[Interface]
Address = $clientipv4/32
Address = $clientipv6/128
PrivateKey = NEWCLKEY
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
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
