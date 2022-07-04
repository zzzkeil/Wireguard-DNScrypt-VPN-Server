# Wireguard-DNScrypt-VPN-Server  x86 / arm64

### Version 2022.05.06
major changes : 
 - add support for ubuntu 22.04
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
* My script base_setup.sh need to installed -> [repository](https://github.com/zzzkeil/base_setups)  
   * if not installed, base_setup.sh will downloaded for you, just follow the instructions.  

----------------------------------------

###### Server x86 - Debian 11 and Ubuntu 20.04 / 22.04 :
```
wget -O  wireguard-dnscrypt_blocklist_x86.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/wireguard-dnscrypt_blocklist_x86.sh
chmod +x wireguard-dnscrypt_blocklist_x86.sh
./wireguard-dnscrypt_blocklist_x86.sh
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

is currently in maintenance - comming back in a few days - 

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


# Other repository : Wireguard-tor-server gateway

https://github.com/zzzkeil/wireguard-dnscrypt-tor-server 

** project target

    encrypted wireguard vpn connection to server
    all traffic from wireguard clients will go over tor network
    dns nameresulotion over dnscrypt (Anonymized DNS) with blocklists
    onion (darknet) nameresulotion over dnscrypt forward to tor


###### BETA ----  Server x86 - Debian 11 and Ubuntu 20.04 / 22.04  :
```
wget -O  beta-wireguard-dnscrypt_blocklist_x86.sh https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/debian_ubuntu/beta-wireguard-dnscrypt_blocklist_x86.sh
chmod +x beta-wireguard-dnscrypt_blocklist_x86.sh
./beta-wireguard-dnscrypt_blocklist_x86.sh
```



== We're Using GitHub Under Protest ==

This project is currently hosted on GitHub.  This is not ideal; GitHub is a
proprietary, trade-secret system that is not Free and Open Souce Software
(FOSS).  We are deeply concerned about using a proprietary system like GitHub
to develop our FOSS project.  We have an
[open {bug ticket, mailing list thread, etc.} ](INSERT_LINK) where the
project contributors are actively discussing how we can move away from GitHub
in the long term.  We urge you to read about the
[Give up GitHub](https://GiveUpGitHub.org) campaign from
[the Software Freedom Conservancy](https://sfconservancy.org) to understand
some of the reasons why GitHub is not a good place to host FOSS projects.

If you are a contributor who personally has already quit using GitHub, please
[check this resource](INSERT_LINK) for how to send us contributions without
using GitHub directly.

Any use of this project's code by GitHub Copilot, past or present, is done
without our permission.  We do not consent to GitHub's use of this project's
code in Copilot.

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/img/GiveUpGitHub.png)
