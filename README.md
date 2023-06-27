# VPN-Server Wireguard DNScrypt AD-Block  x86 / arm64
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/320px-Logo_of_WireGuard.svg.png" height="75">   <img src="https://raw.github.com/dnscrypt/dnscrypt-proxy/master/logo.png" height="100">

![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white) ![Fedora](https://img.shields.io/badge/Fedora-294172?style=for-the-badge&logo=fedora&logoColor=white) ![Rocky Linux](https://img.shields.io/badge/-Rocky%20Linux-%2310B981?style=for-the-badge&logo=rockylinux&logoColor=white) ![Cent OS](https://img.shields.io/badge/cent%20os-002260?style=for-the-badge&logo=centos&logoColor=F0F0F0) ![Alma Linux](https://img.shields.io/badge/alma%20linux-294172?style=for-the-badge&logo=almalinux&logoColor=F0F0F0)

[![https://hetzner.cloud/?ref=iP0i3O1wRcHu](https://img.shields.io/badge/maybe_you_can_support_me_-_my_VPS_hoster_thanks_(referral_link)-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://hetzner.cloud/?ref=iP0i3O1wRcHu) 

### Version 2023.06.27
major changes : 
 - X86_64 and ARM64
 - Debian 12, Ubuntu 22.04, Fedora 38, Rocky Linux 9, CentOS Stream 9, AlmaLinux 9
 - removed unbound  ( only DNScrypt is used )
 - replaced ufw with firewalld
 - all other things i forgot :)

## **Setup Wireguard VPN Server fast and easy  - with ** 
* on X86_64 or ARM64 systems
* DNScrypt with anonymized_dns / DNSSEC
* Ad-, Maleware-, ..., Blocking
* 3 config files  for your clients
* add or remove clients with add_client.sh / remove_client.sh 
* backup, restore and unistall options

## How to install :  
###### Server x86_64 and ARM64 - Debian 12, Ubuntu 22.04, Fedora 38, Rocky Linux 9, CentOS Stream 9, AlmaLinux 9:
```
wget -O  wireguard_dnscrypt_setup.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/wireguard_dnscrypt_setup.sh
chmod +x wireguard_dnscrypt_setup.sh
./wireguard_dnscrypt_setup.sh
```
* Copy the lines above, execute and follow the instructions  
* Use a fresh / clean **server** os > Debian 12, Ubuntu 22.04, Fedora 38, Rocky Linux 9, CentOS Stream 9, AlmaLinux 9:
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


Badge found and used from : [github - Ileriayo - mark-down-badges](https://github.com/Ileriayo/markdown-badges)
