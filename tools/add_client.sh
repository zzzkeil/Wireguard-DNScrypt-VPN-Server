#!/bin/bash
clear
echo " To add a new client follow this steps"
echo "."
echo "."
echo "."
echo "."

ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0port=$(grep ListenPort /etc/wireguard/wg0.conf | tr -d 'ListenPort = ')

###
echo "Client Name"
echo "don´use a clientname from client1 to client5 !"
echo "only one word - no space in names !"
echo "these clientnames exsist/reserved by the setupscript!"
read -p "client name: " -e -i newclient clientname
echo "------"
echo "Client IPv4"
echo "do not use an ipv4 address below 10.$ipv4network.20"
echo "do not use an address that is already in use"
read -p "client IPv4: " -e -i 10.$ipv4network.20 clientipv4
echo "------"
echo "Client IPv6"
echo "do not use an ipv6 address below fd42:$ipv6network::20"
echo "do not use an address that is already in use"
read -p "client IPv6: " -e -i fd42:$ipv6network::20 clientipv6
echo "------"
  
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
DNS = 10.$ipv4network.1, fd42:$ipv6network::1
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
