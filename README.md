# Wireguard-DNScrypt-VPN-Server  x86 / arm64
 
### Version 2023.06.27
major changes : 
 - X86_64 and ARM64
 - Debian 12, Fedora 38, Rocky Linux 9, CentOS Stream 9, AlmaLinux 9
 - removed unbound  ( only DNScrypt is used )
 - replaced ufw with firewalld
 - remove all support for ubuntu ... comeback later
 - all other things i forgot :)

## **Setup Wireguard VPN Server fast and easy  - with ** 
* on X86_64 or ARM64 systems
* DNScrypt with anonymized_dns / DNSSEC
* Ad-, Maleware-, ..., Blocking
* 3 config files  for your clients
* add or remove clients with add_client.sh / remove_client.sh 
* backup, restore and unistall options

## How to install :  
###### Server x86_64 and ARM64 - Debian 12, Fedora 38, Rocky Linux 9, CentOS Stream 9, AlmaLinux 9:
```
wget -O  wireguard_dnscrypt_setup.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/wireguard_dnscrypt_setup.sh
chmod +x wireguard_dnscrypt_setup.sh
./wireguard_dnscrypt_setup.sh
```
* Copy the lines above, execute and follow the instructions  
* Use a fresh / clean **server** os > Debian 12, Fedora 38, Rocky Linux 9, CentOS Stream 9
* My script base_setup.sh need to installed -> [repository](https://github.com/zzzkeil/base_setups)  
   * if not installed, base_setup.sh will downloaded for you, just follow the instructions.  

@ the end you see the QR Code for your wiregaurd app.

## How to add or remove clients :
```
run ./add_client.sh or ./remove_client.sh
```
## How to backup or restore settings :
```
run ./wg_config_backup.sh or ./wg_config_restore.sh
```
