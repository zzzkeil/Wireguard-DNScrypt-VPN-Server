# Wireguard-DNScrypt-VPN-Server  x86 / arm64

## 2023.06.24 a bigger update comming soon ...
## Some files get removed, and one script will work on x86_64 / ARM64 and Debian / Fedora
 


### Project  codeberg

[project home on codeberg](https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server)

### Version 2023.06.24
major changes : 
 - unified Debian 12, Fedora 38 and X86_64, ARM64 in one script 
 - add arm64 support
 - removed unbound  ( only DNScrypt is used )
 - replaced ufw with firewalld for both systems 
 - remove all support for ubuntu ...
 - all other things i forgot :)

## **Setup Wireguard VPN Server fast and easy  - with ** 
* DNScrypt with anonymized_dns / DNSSEC
* Ad-, Maleware-, ..., Blocking
* 3 config files  for your clients
* add or remove clients with add_client.sh / remove_client.sh 
* backup, restore and unistall options

## How to install :  
* Use a fresh / clean and  up to date  **server** os   debian 12 (11) or fedora 38 (37)
* Copy the lines for your system below, and run it and follow the instructions  
* My script base_setup.sh need to installed -> [repository](https://codeberg.org/zzzkeil/base_setups)  
   * if not installed, unified_base_setup.sh will downloaded for you, just follow the instructions.  

----------------------------------------

###### In Testing (mayby works) Server x86_64 and ARM64 - Debian 12 (11) and Fedora 38 (37):
```
wget -O  unified_wireguard_dnscrypt_setup.sh https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server/raw/branch/master/unified_wireguard_dnscrypt_setup.sh
chmod +x unified_wireguard_dnscrypt_setup.sh
./unified_wireguard_dnscrypt_setup.sh
```


###### Server x86 - Debian 12  (11):
```
wget -O  wireguard-dnscrypt_blocklist_x86.sh https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server/raw/branch/master/debian/wireguard-dnscrypt_blocklist_x86.sh
chmod +x wireguard-dnscrypt_blocklist_x86.sh
./wireguard-dnscrypt_blocklist_x86.sh
```

###### Server arm64 - Debian 12  (11):
```
wget -O  wireguard-dnscrypt_blocklist_arm64.sh https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server/raw/branch/master/debian/wireguard-dnscrypt_blocklist_arm64.sh
chmod +x wireguard-dnscrypt_blocklist_arm64.sh
./wireguard-dnscrypt_blocklist_arm64.sh
```


@ the end you see the QR Code for your wiregaurd app.


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
