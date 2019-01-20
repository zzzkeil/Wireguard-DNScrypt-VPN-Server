# Wireguard-DNScrypt-VPN-Server
Wireguard VPN server with DNScrypt / DNSSEC  ( ipv4 and ipv6 )


-----------------------------------------
How to install :

curl -o  wireguard_dnscrypt_setup.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/wireguard_dnscrypt_setup.sh

chmod +x wireguard_dnscrypt_setup.sh

./wireguard_dnscrypt_setup.sh
-----------------------------------------


-----------------------------------------
This script installs Wireguard VPN Server and create one client config.

(Check todo list for next versions)

To get a little more security, 
it changes the SSH port to 40, with new ""better"" keys and

install UFW and setup some iptabels with some sysctl.conf mods.

DNS is in the tunnel. Unbound will forward querys to DNScrypt-proxy.

@ the end you see the QR Code for your wiregaurd app.
example:
[![example](https://zeroaim.de/01/qrtest.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)

-----------------------------------------
