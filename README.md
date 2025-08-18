## VPN-Server Wireguard DNScrypt AD-Block - Pi-Hole optional
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/320px-Logo_of_WireGuard.svg.png" height="75">   <img src="https://raw.github.com/dnscrypt/dnscrypt-proxy/master/logo.png" height="100">

![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

[![https://hetzner.cloud/?ref=iP0i3O1wRcHu](https://img.shields.io/badge/maybe_you_can_support_me_-_my_VPS_hoster_hetzner_(referral_link)_thanks-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://hetzner.cloud/?ref=iP0i3O1wRcHu) 

### Version 2025.08.04
major changes : 
 - Debian and Ubuntu only for the future, to much work for the others, less time ....
 - Pi-Hole as option 
 - Nextcloud as option
 - add and remove of clients now with "checks"
 - only one client after install, so you can add and name yours  


## **Setup Wireguard VPN Server fast and easy  - with ** 
* on X86_64 or ARM64 systems
* DNScrypt with anonymized_dns / DNSSEC
* Ad-, Maleware-, Threat Intelligence Feeds, ..., blocking
* add or remove clients with add_client.sh / remove_client.sh 
* backup, restore and unistall options


# How to install Debian 13 and Ubuntu 24.04 (optional: nextcloud):  
###### Server x86_64 and ARM64 - 
###### Pi-Hole or Nextcloud can only accessed with wireguard, it´s not puplic available.   hope so .... ;)

With Pi-Hole and DNScrypt :
```
wget -O  setup_wg_adblock.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/refs/heads/master/pihole_dnscrypt_debian13_ubuntu24.sh
chmod +x setup_wg_adblock.sh
./setup_wg_adblock.sh

```
DNScrypt with adblock only :
```
wget -O  setup_wg_adblock.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/refs/heads/master/dnscrypt_adblock_debian13_ubuntu24.04.sh
chmod +x setup_wg_adblock.sh
./setup_wg_adblock.sh
```

* Copy the lines above, execute and follow the instructions  
* Use a fresh / clean **server** os > Debian 13 or Ubuntu 24.04:
* My script base_setup.sh need to installed -> [repository](https://github.com/zzzkeil/base_setups)  
   * if not installed, base_setup.sh will downloaded for you, just follow the instructions.
* Optional: Nextcloud can be installed afterwards

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
