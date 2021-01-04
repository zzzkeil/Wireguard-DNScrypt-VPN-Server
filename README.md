# Wireguard-DNScrypt-VPN-Server  x86 / arm64

### Version 2021.01.04 running / testing  
major changes : update to dnscrypt 2.0.45 with blocked_names  
take a look here : [dnscrypt changelog](https://github.com/DNSCrypt/dnscrypt-proxy/releases/tag/2.0.45)

**Setup Wireguard VPN Server in under 5 minutes** 
* ipv4 and ipv6
* DNScrypt / DNSSEC (unbound)
* Ad-, Maleware-, ..., Blocking
* 5 config files ready for clients   ( one with QR-Code in terminal )
* add_client.sh / remove_client.sh under development in tools

## How to install :  
* Use a fresh / clean **server** os  ( e.g. Ubuntu 20.04 is tested ) 
* The server has to be prepared with my script base_setup.sh -> [repository](https://github.com/zzzkeil/base_setups)  
  * if the base is not installed, the script below will download this one for you, follow the instructions.  
* Copy the lines for your system below, and run it and follow the instructions.
----------------------------------------

###### Server x86 - Ubuntu 20.04 :
```
wget -O  wireguard-dkms_dnscrypt_blocklist.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dkms_dnscrypt_blocklist_x86.sh
chmod +x wireguard-dkms_dnscrypt_blocklist_x86.sh
./wireguard-dkms_dnscrypt_blocklist_x86.sh
```

###### Server arm64 - Ubuntu 20.04 (status: not finished) :
```
(testing on a pi 4 on my home network)

wget -O  wireguard-dkms_dnscrypt_blocklist.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dkms_dnscrypt_blocklist_arm64.sh
chmod +x wireguard-dkms_dnscrypt_blocklist_arm64.sh
./wireguard-dkms_dnscrypt_blocklist_arm64.sh

```
-----------------------------------------

## How to add or remove clients :
```
run ./add_client.sh or remove_client.sh
```

@ the end you see the QR Code for your wiregaurd app.
example:
[![example](https://zeroaim.de/img/wgexsqr.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)

-----------------------------------------





( *less then 5 minutes on my v-server together with base_setup.sh ) 
