# Wireguard with dnscrypt and Pi-hole. 
## Block ad´s, maleware & more. 
### If needed, a nextcloud behind wireguard, no public access.
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Logo_of_WireGuard.svg/320px-Logo_of_WireGuard.svg.png" height="75">   <img src="https://raw.github.com/dnscrypt/dnscrypt-proxy/master/logo.png" height="100">

![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

[![https://hetzner.cloud/?ref=iP0i3O1wRcHu](https://img.shields.io/badge/support_me_-_my_VPS_hoster_hetzner_(referral_link)_thanks-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://hetzner.cloud/?ref=iP0i3O1wRcHu) 

### Version 2025.08.21
major changes : 
 - whiptail as UI
 - Checks if input is correct....
 - Pi-Hole 
 - Nextcloud as option 

## **Setup Wireguard VPN Server fast and easy  - with ** 
* on X86_64 or ARM64 systems
* Pi-hole for customising Ad-, Maleware-, Threat Intelligence Feeds blocking
* DNScrypt with anonymized_dns / DNSSEC
* UI for install and config 

# How to install Debian 13 and Ubuntu 24.04:  
###### Server x86_64 and ARM64 - 
###### Pi-hole and Nextcloud can only accessed with wireguard, it´s not puplic available.

With Pi-Hole and DNScrypt :
```
wget -O  setup_menu.sh https://raw.githubusercontent.com/zzzkeil/Wireguard_Pi-hole_DNScrypt_Nextcloud/refs/heads/master/setup_menu.sh
chmod +x setup_menu.sh
./setup_menu.sh

```
* Copy the lines above, execute and follow the instructions  
* Use a fresh / clean **server** with Debian **13** or Ubuntu **24.04**
* Optional: **Nextcloud** can be installed afterwards
  
## Menu
```
run ./setup_menu.sh to open a menu 
```











Badge found and used from : [github - Ileriayo - mark-down-badges](https://github.com/Ileriayo/markdown-badges)
