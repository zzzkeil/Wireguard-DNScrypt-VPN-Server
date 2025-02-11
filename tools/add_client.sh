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

### AllowedIPs options
echo -e " -- AllowedIPs handling - make your decision -- "
echo ""
echo -e "${GREEN}Press any key to tunnel all trafic over wireguard ${ENDCOLOR}"
echo "or"
echo -e "${RED}Press [A] to exclude local ips > Class A: 10. Class B: 172.16. Class C: 192.168. (advanced user)${ENDCOLOR}"
echo ""
read -p "" -n 1 -r
if [[ ! $REPLY =~ ^[Aa]$ ]]
then
allownet="0.0.0.0/0, ::/0"
else
allownet="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, 10.$ipv4network.0/24, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, fd42:$ipv6network::/64, fe00::/9, fec0::/10, ff00::/8"
fi

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
