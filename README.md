# Wireguard-DNScrypt-VPN-Server  x86 / arm64

### Project moved to codeberg

[project home on codeberg](https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server)

## Setup (source form codeberg.org) :

### Version 2022.06.18
major changes : 
 - add support for debian 12 
 - add arm64 support
 - remove all support for ubuntu .......
 - all other things i forgot :)

## **Setup Wireguard VPN Server fast and easy  - with ** 
* DNScrypt with anonymized_dns / DNSSEC (unbound)
* Ad-, Maleware-, ..., Blocking
* 3 config files  for your clients
* add or remove clients with add_client.sh / remove_client.sh 
* backup, restore and unistall options

## How to install :  
* Use a fresh / clean and  up to date  **server** os   debian or ubuntu
* Copy the lines for your system below, and run it and follow the instructions  
* My script base_setup.sh need to installed -> [repository](https://gitlab.com/zzzkeil/base_setups)  
   * if not installed, base_setup.sh will downloaded for you, just follow the instructions.  

----------------------------------------

###### Server x86 - Debian 12  (11):
```
wget -O  wireguard-dnscrypt_blocklist_x86.sh https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server/raw/branch/master/debian_ubuntu/wireguard-dnscrypt_blocklist_x86.sh
chmod +x wireguard-dnscrypt_blocklist_x86.sh
./wireguard-dnscrypt_blocklist_x86.sh
```

###### Server arm64 - Debian 12  (11):
```
wget -O  wireguard-dnscrypt_blocklist_arm64.sh https://codeberg.org/zzzkeil/Wireguard-DNScrypt-VPN-Server/raw/branch/master/debian_ubuntu/wireguard-dnscrypt_blocklist_arm64.sh
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
