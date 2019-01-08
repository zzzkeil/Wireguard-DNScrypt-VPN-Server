# Wireguard-DNScrypt-VPN-Server

# Just a test for now.


Wireguard VPN server with DNScrypt / DNSSEC  ( ipv4 and ipv6 )


This script installs Wireguard VPN Server and create one client config.

( Version 0.1 - only for Ubuntu 18.04 )

( Check todo list for next versions )

To get a little more security, 
it changes the SSH port to 40, with new ""better"" keys and


install UFW and setup some iptabels with some sysctl.conf mods.


DNS is in the tunnel. Unbound will forward querys to DNScrypt-proxy.


@ the end you see the QR Code for your wiregaurd app.
example:
[![example](https://zeroaim.de/01/qrtest.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)



