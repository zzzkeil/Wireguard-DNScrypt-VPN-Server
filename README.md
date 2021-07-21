# Wireguard-DNScrypt-VPN-Server  x86 / arm64

### Version 2021.07.17
major changes : 
 - activate dnscrypt - anonymized_dns
 - option to edit your blocklist file 
 - backup / restore option 
 - uninstaller
 - ufw only ipv4 rule for wireguard incomming 



## **Setup Wireguard VPN Server in under 5 minutes** 
#### ( *less then 5 minutes on my v-server together with base_setup.sh ) 
* ipv4 and ipv6
* DNScrypt / DNSSEC (unbound)
* Ad-, Maleware-, ..., Blocking
* 5 config files ready for clients   ( one with QR-Code in terminal )
* add_client.sh / remove_client.sh under development in tools

## How to install :  
* Use a fresh / clean **server** os  ( e.g. Ubuntu 20.04 is tested ) 
* The server has to be prepared with my script base_setup.sh -> [repository](https://github.com/zzzkeil/base_setups)  
  * if the base is not installed, the script below will download this one for you, follow the instructions.  
* Copy the lines for your system below, and run it and follow the instructions  

----------------------------------------

###### Server x86 - Ubuntu 20.04 :
```
wget -O  wireguard-dkms_dnscrypt_blocklist_x86.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dkms_dnscrypt_blocklist_x86.sh
chmod +x wireguard-dkms_dnscrypt_blocklist_x86.sh
./wireguard-dkms_dnscrypt_blocklist_x86.sh
```


@ the end you see the QR Code for your wiregaurd app.
<details>
  <summary>example: click to expand!</summary>

[![example](https://wp.zeroaim.de/img/wgexsqr.png)](https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server)
</details>
-----------------------------------------





###### Server arm64 - Ubuntu 20.04 (status: not finished) :
<details>
  <summary>Click to expand!</summary>
  
```
(testing on a pi 4 on my home network)

wget -O  wireguard-dkms_dnscrypt_blocklist_arm64.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dkms_dnscrypt_blocklist_arm64.sh
chmod +x wireguard-dkms_dnscrypt_blocklist_arm64.sh
./wireguard-dkms_dnscrypt_blocklist_arm64.sh

```
 </details>
-----------------------------------------

## How to add or remove clients :
```
run ./add_client.sh or ./remove_client.sh
```


## How to backup or restore settings :
```
run ./wg_config_backup.sh or ./wg_config_restore.sh
```
-----------------------------------------
