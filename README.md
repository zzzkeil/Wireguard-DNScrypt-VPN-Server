# Wireguard-DNScrypt-VPN-Server
Wireguard VPN server with DNScrypt / DNSSEC  ( ipv4 and ipv6 )


This script installs Wireguard VPN Server and create one client config.

( Version 0.1 - only for Ubuntu 18.04 )

To get a little more security, 
it changes the SSH port to 40,
install UFW and setup some iptabels with some sysctl.conf mods.


DNS is in the tunnel. Unbound will forward querys to DNScrypt-proxy.


@ the end you see the QR Code for your wiregaurd app.


Just a test for now.
Script version 0.1 has no Options !
