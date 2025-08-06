#!/bin/bash

# visual text settings
RED="\e[31m"
GREEN="\e[32m"
GRAY="\e[37m"
YELLOW="\e[93m"

REDB="\e[41m"
GREENB="\e[42m"
GRAYB="\e[47m"
ENDCOLOR="\e[0m"

if whiptail --title "Hi, lets start" --yesno "Bulid date of this scriptfile: 2025.08.03\nThis script install and configure:\nwireguard, dnscrypt, pihole\nMore info: https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server\n\nRun script now ?\n" 15 80; then
echo ""
else
    echo "Ok, no install right now. cu have a nice day."
    exit 1
fi   

### root check
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${RED}Sorry, you need to run this as root${ENDCOLOR}"
	exit 1
fi

### OS check
echo -e "${GREEN}OS check ${ENDCOLOR}"

. /etc/os-release

if [[ "$ID" = 'debian' ]]; then
 if [[ "$VERSION_ID" = '13' ]]; then
   echo -e "${GREEN}OS = Debian ${ENDCOLOR}"
   systemos=debian
   fi
fi

if [[ "$ID" = 'ubuntu' ]]; then
 if [[ "$VERSION_ID" = '24.04' ]]; then
   echo -e "${GREEN}OS = Ubuntu ${ENDCOLOR}"
   systemos=ubuntu
   fi
fi


if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 13 and Ubuntu 24.04 !${ENDCOLOR}"
   exit 1
fi


### Architecture check for dnsscrpt 
ARCH=$(uname -m)
if [[ "$ARCH" == x86_64* ]]; then
  dnsscrpt_arch=x86_64
elif [[ "$ARCH" == aarch64* ]]; then
    dnsscrpt_arch=arm64
else
   echo -e "${RED}This script is only for x86_64 or ARM64  Architecture !${ENDCOLOR}"
   exit 1
fi
echo -e "${GREEN}Arch = $dnsscrpt_arch ${ENDCOLOR}"


### base_setup check
#if [[ -e /root/base_setup.README ]]; then
#     echo -e "base_setup script installed = ${GREEN}ok${ENDCOLOR}"
#	 else
#	 echo -e " ${YELLOW}Warning:${ENDCOLOR}"
#	 echo -e " ${YELLOW}You need to install my base_setup script first!${ENDCOLOR}"
#	 echo -e " ${YELLOW}Starting download base_setup.sh from my repository${ENDCOLOR}"
#	 echo ""
#	 echo ""
#	 wget -O  base_setup_2025.sh https://raw.githubusercontent.com/zzzkeil/base_setups/refs/heads/master/base_setup_2025.sh
 #        chmod +x base_setup_2025.sh
#	 echo ""
#	 echo ""
 #        echo -e " Now run ${YELLOW}./base_setup_2025.sh${ENDCOLOR} manualy and reboot, then run this script again."
#	 echo ""
#	 echo ""
#	 exit 1
#fi


### script already installed check
#if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
 #    echo
#	 echo
 #        echo -e "${YELLOW}Looks like this script is already installed${ENDCOLOR}"
#	 echo -e "${YELLOW}This script is only need for the first install${ENDCOLOR}"
#	 echo ""
#	 echo "To add or remove clients run"
 #        echo -e " ${YELLOW}./add_client.sh${ENDCOLOR} to add clients"
  #       echo -e " ${YELLOW}./remove_client.sh${ENDCOLOR} to remove clients"
##	 echo ""
#	 echo  "To backup or restore your settings run"
#	 echo -e " ${YELLOW}./wg_config_backup.sh${ENDCOLOR} "
#	 echo -e " ${YELLOW}./wg_config_restore.sh${ENDCOLOR}"
#	 echo ""
#	 echo  "To uninstall run"
#	 echo -e " ${RED}./uninstaller_back_to_base.sh${ENDCOLOR} "
##	 echo ""
#	 echo "For - News / Updates / Issues - check my github site"
#	 echo "https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server"
#	 echo
#	 echo
#	 exit 1
#fi


### wireguard options with input checks
    ### lets take care of your ssh port 
ssh_port=$(grep -i "^Port" /etc/ssh/sshd_config | awk '{print $2}')
is_valid_port() {
    local wgport="$1"
    if [[ "$wgport" =~ ^[0-9]+$ ]] && [ "$wgport" -ge 1025 ] && [ "$wgport" -le 65535 ] && [ "$wgport" -ne 5335 ] && [ "$wgport" -ne $ssh_port ]; then
        return 0
    else
        return 1
    fi
}

while true; do
    wg0port=$(whiptail --title "Wireguard Port Settings" --inputbox "Choose a free port 1025-65535\nDo not use port $ssh_port ssh and 5335 dnscrypt\nDo not use a used port!\nTo list all currently activ ports, cancel now and you see a list\nThen start this script again" 15 80 "54234" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_valid_port "$wg0port"; then
            break
        else
            whiptail --title "Invalid Port" --msgbox "Invalid port number. Please enter a port number between 1025 and 65535. Do not use port $ssh_port, 5335" 15 80
        fi
    else
        echo "Ok, cancel. No changes to system was made. Maybe try it again?"
	echo "here is your list of currently open ports:"
	ss -tuln | awk '{print $5}' | cut -d':' -f2 | sort -n | uniq
        echo ""
        echo "Now run the script again, and aviod useing a port from above"
	echo ""
        echo ""
        exit 1
    fi
done

is_private_ipv4_ending_with_1() {
    local ipv4="$1"
    if [[ "$ipv4" =~ ^10\.[0-9]{1,3}\.[0-9]{1,3}\.1$ ]]; then
        return 0  # (10.0.0.0 to 10.255.255.255) and ends with .1
    elif [[ "$ipv4" =~ ^172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.1$ ]]; then
        return 0  # (172.16.0.0 to 172.31.255.255) and ends with .1
    elif [[ "$ipv4" =~ ^192\.168\.[0-9]{1,3}\.1$ ]]; then
        return 0  # (192.168.0.0 to 192.168.255.255) and ends with .1
    else
        return 1  # Invalid private IP or doesn't end with .1
    fi
}

while true; do
    wg0networkv4=$(whiptail --title "Wireguard ipv4 settings" --inputbox "Enter a private IP address ending with .1\nPrivate ip ranges:\n10.0.0.1 to 10.255.255.254\nor\n172.16.0.1 to 172.31.255.254\nor\n192.168.0.1 to 192.168.255.254" 15 80 "10.11.12.1" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_private_ipv4_ending_with_1 "$wg0networkv4"; then
            break  
        else
            whiptail --title "Invalid Input" --msgbox "Invalid input. Please enter a private IP address ending with .1" 15 80
        fi
    else
         echo "Ok, cancel. No changes to system was made. Maybe try it again?"
        exit 1
    fi
done


is_private_ipv6_ending_with_1() {
    local ipv6="$1"
     if [[ "$ipv6" =~ ^fd[0-9a-fA-F]{2}(:[0-9a-fA-F]{1,4})*::1$ ]] then # Matches IPv6 Unique Local Address (ULA) ending with ::1 (fd00::1)
        return 0
    else
        return 1
    fi
}

while true; do
    wg0networkv6=$(whiptail --title "Wireguard ipv6 settings" --inputbox "Enter a private IPv6 address ending with ::1\nPrivate ip ranges:\nfd00:: to fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff" 15 80 "fd42:10:11:12::1" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_private_ipv6_ending_with_1 "$wg0networkv6"; then
            break 
        else
            whiptail --title "Invalid Input" --msgbox "Invalid input. Please enter a private IPv6 address ending with ::1" 15 80
        fi
    else
         echo "Ok, cancel. No changes to system was made. Maybe try it again?"
        exit 1
    fi
done


is_valid_keepalive() {
    local keepalive="$1"
    if [[ "$keepalive" =~ ^[0-9]+$ ]] && [ "$keepalive" -ge 0 ] && [ "$keepalive" -le 999 ]; then
        return 0
    else
        return 1
    fi
}

while true; do
    wg0keepalive=$(whiptail --title "Wireguard keepalive settings" --inputbox "Enter number in secconds (0-999)\n Default is 0 (off)" 15 80 "0" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_valid_keepalive "$wg0keepalive"; then
            break
        else
            whiptail --title "Invalid input" --msgbox "Invalid number. Please enter a number between 0 and 999." 15 80
        fi
    else
         echo "Ok, cancel. No changes to system was made. Maybe try it again?"
        exit 1
    fi
done

is_valid_mtu() {
    local mtu="$1"
    if [[ "$mtu" =~ ^[0-9]+$ ]] && [ "$mtu" -ge 1280 ] && [ "$mtu" -le 1500 ]; then
        return 0
    else
        return 1
    fi
}

while true; do
    wg0mtu=$(whiptail --title "Clients MTU settings" --inputbox "Enter MTU size from 1280 to 1500\nDefault is 1420 - a common value.\n1380 is reasonable size, too" 15 80 "1420" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_valid_mtu "$wg0mtu"; then
            break 
        else
            whiptail --title "Invalid MTU" --msgbox "Invalid MTU. Please enter a number between 1280 and 1500." 15 80
        fi
    else
         echo "Ok, cancel. No changes to system was made. Maybe try it again?"
        exit 1
    fi
done

wg0networkv4_0=$(echo "$wg0networkv4" | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\.\)1$/\10/')
wg0networkv6_0=$(echo "$wg0networkv6" | sed 's/1\([^1]*\)$/\1/')



echo ""

if whiptail --title "Client traffic over wireguard" --yesno "Yes =  Tunnel all traffic over wireguard\n       0.0.0.0/0, ::/0\n\nNo  =  Exclude private network ip's\n       10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 not over wireguard\n" 15 80; then
allownet="0.0.0.0/0, ::/0"
else
allownet="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, $wg0networkv4_0/24, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, $wg0networkv6_0/64, fe00::/9, fec0::/10, ff00::/8"
fi  


echo 'Dpkg::Progress-Fancy "1";
APT::Color "1";
'> /etc/apt/apt.conf.d/99progressbar



whiptail --title "OS Updates" --msgbox "Let's check for updates and upgrade." 15 80

run_update() {
    whiptail --title "APT UPDATE" --backtitle "Checking Updates" --infobox "Updating package list..." 10 80
    apt-get update --show-progress 2>&1 | \
    whiptail --title "APT UPDATE" --backtitle "Waiting" --gauge "Updating package lists..." 10 80 0
    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "APT UPDATE" --msgbox "Package list update failed. Please check your network connection." 10 60
        exit 1
    fi
}

run_upgrade() {
    whiptail --title "APT UPGRADE" --backtitle "Upgrading System" --infobox "Upgrading system packages..." 10 80
    apt-get upgrade --show-progress -y 2>&1 | \
    whiptail --title "APT UPGRADE" --backtitle "Waiting" --gauge "Upgrading system packages..." 10 80 0
    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "APT UPGRADE" --msgbox "Package upgrade failed. Please check your system." 10 60
        exit 1
    fi
}

run_autoremove() {
    whiptail --title "APT AUTOREMOVE" --backtitle "Cleanup" --infobox "Removing unnecessary packages..." 10 80
    apt-get autoremove -y 2>&1 | \
    whiptail --title "APT AUTOREMOVE" --backtitle "Waiting" --gauge "Removing unnecessary packages..." 10 80 0
    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "APT AUTOREMOVE" --msgbox "Autoremove failed. Please check your system." 10 60
        exit 1
    fi
}

# Run all functions
run_update
run_upgrade
run_autoremove


packages1="qrencode python-is-python3 curl linux-headers-$(uname -r) sqlite3 resolvconf"
packages1="wireguard wireguard-tools"
whiptail --title "Package Installation" --infobox "Installing required packages. Please wait..." 15 80

install_packages1() {
    apt-get install -y $packages1 --quiet | \
    whiptail --title "Installing OS packages" --backtitle "Please Wait" --gauge "Installing OS packages..." 10 80 0 2>/dev/tty
}

install_packages1
if [ $? -eq 0 ]; then
    echo ""
else
    whiptail --title "Installation Failed" --msgbox "OS package installation failed. Please check the error messages." 15 80
    exit 1
fi

install_packages2() {
    apt-get install -y $packages2 --quiet | \
    whiptail --title "Installing wireguard-tools" --backtitle "Please Wait" --gauge "Installing wireguard..." 10 80 0 2>/dev/tty
}

install_packages2
if [ $? -eq 0 ]; then
    echo ""
else
    whiptail --title "Installation Failed" --msgbox "Wireguard installation failed. Please check the error messages." 15 80
    exit 1
fi






# List of URLs to download
urls=(
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/add_client.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/remove_client.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_backup.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/wg_config_restore.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/uninstaller_back_to_base.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/refs/heads/master/nextcloud-behind-wireguard.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/dnscrypt-proxy-pihole.toml"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/tools/dnscrypt-proxy-update.sh"
    "https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/refs/heads/master/tools/pihole.toml"
)

# Function to download files in the background
download_files() {
    total_files=${#urls[@]}  # Total number of files
    current_file=0  # Starting file counter

    # Loop through each URL and download the file
    for url in "${urls[@]}"; do
        filename=$(basename "$url")

        # Check if file already exists, and prompt for overwrite if needed
        if [ -f "$filename" ]; then
            echo "File $filename already exists. Overwriting..."
        fi

        # Start download in background
        curl -s -o "$filename" "$url" &  # -s silences curl's output
    done

    # Wait for all background downloads to complete
    wait
}

# Show info box before starting
whiptail --title "File Download" --msgbox "Downloading required files from:\n - My github repo /tools an so on\n - " 15 80

# Start the download process
download_files
clear

chmod +x add_client.sh
chmod +x remove_client.sh
chmod +x wg_config_backup.sh
chmod +x wg_config_restore.sh
chmod +x uninstaller_back_to_base.sh
chmod +x nextcloud-behind-wireguard.sh

mkdir /etc/dnscrypt-proxy/
mv dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
mv dnscrypt-proxy-update.sh /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh
chmod +x /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh

mkdir /etc/pihole
mv pihole.toml /etc/pihole/pihole.toml


whiptail --title "Downloading DNSCrypt Proxy" --msgbox "Downloading DNSCrypt Proxy for architecture: $dnsscrpt_arch" 15 80
curl -L -o /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.12/dnscrypt-proxy-linux_${dnsscrpt_arch}-2.1.12.tar.gz"
if [ $? -eq 0 ]; then
echo ""
else
    whiptail --title "Download Failed" --msgbox "Failed to download DNSCrypt Proxy. Please check your network connection." 15 80
    exit 1
fi

tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
mv -f /etc/dnscrypt-proxy/linux-$dnsscrpt_arch/* /etc/dnscrypt-proxy/
cp /etc/dnscrypt-proxy/example-blocked-names.txt /etc/dnscrypt-proxy/blocklist.txt


systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start




echo -e " ${GRAYB}##${ENDCOLOR} ${YELLOW}pihole setup part  ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}WebUI access is only over wireguard possible ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}Press enter, Pi-hole setup starts with source from https://install.pi-hole.net --unattended mode ${ENDCOLOR}"
echo -e " ${GRAYB}##>${ENDCOLOR}" 
echo ""
read -p "Press Enter to continue..."
whiptail --title "Downloading Pihole" --msgbox "Download source from https://install.pi-hole.net\nand runing pihole-install.sh --unattended  mode" 15 80
curl -L -o pihole-install.sh https://install.pi-hole.net
if [ $? -eq 0 ]; then
echo ""
else
    whiptail --title "Download Failed" --msgbox "Failed to download Pihole. Please check your network connection." 15 80
    exit 1
fi
chmod +x pihole-install.sh
. pihole-install.sh --unattended 

while true; do
    whiptail --title "Pi-hole Password Setup" --infobox "Please enter a password for your Pi-hole admin interface." 15 80
    pihole_password=$(whiptail --title "Pi-hole Password" --inputbox "Enter your Pi-hole admin password (at least 8 characters):" 15 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        whiptail --title "Cancelled" --msgbox "Password setup was cancelled.\n WARNING NO PASSWORD IS SET\n  Take care" 15 60
    fi
    if [ ${#pihole_password} -ge 8 ]; then
	whiptail --title "Password Set" --msgbox "Password has been set successfully!" 15 60
        break 
    else
        whiptail --title "Invalid Password" --msgbox "Password must be at least 8 characters long. Please try again." 15 60
    fi
done


echo " Add more list to block "
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt', 1, 'MultiPRO-Extended')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt', 1, 'ThreatIntelligenceFeeds')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://easylist.to/easylist/easylist.txt', 1, 'Easylist')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://easylist.to/easylist/easyprivacy.txt', 1, 'Easyprivacy')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://secure.fanboy.co.nz/fanboy-annoyance.txt', 1, 'fanboy-annoyance')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://easylist.to/easylist/fanboy-social.txt', 1, 'fanboy-social')"
sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://secure.fanboy.co.nz/fanboy-cookiemonster.txt', 1, 'fanboy-cookiemonster')"
pihole -g

clear
### create crontabs to update dnscrypt and pihole
(crontab -l ; echo "59 23 * * 6 /etc/dnscrypt-proxy/dnscrypt-proxy-update.sh") | sort - | uniq - | crontab -
(crontab -l ; echo "0 23 * * 3 pihole -up") | sort - | uniq - | crontab -



#### create files for configs  
echo "
!!! do not delete or modify this file
!!  This file contains values line by line, used for config, backups and restores

--- ip settings
ipv4
$wg0networkv4
ipv6
$wg0networkv6
--- port and misc settings
wg0
$wg0port
$wg0mtu
$wg0keepalive
---

For - News / Updates / Issues - check my gitlab site
https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server
" > /root/Wireguard-DNScrypt-VPN-Server.README


firewalldstatus="$(systemctl is-active firewalld)"
if [ "${firewalldstatus}" = "active" ]; then
echo "ok firewalld is running"
else 
systemctl restart firewalld  
fi

### setup firewalld and sysctl
hostipv4=$(hostname -I | awk '{print $1}')
hostipv6=$(hostname -I | awk '{print $2}')

firewall-cmd --zone=public --add-port="$wg0port"/udp

firewall-cmd --zone=trusted --add-source=$wg0networkv4_0/24
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s $wg0networkv4_0/24 ! -d $wg0networkv4_0/24 -j SNAT --to "$hostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --add-source=$wg0networkv6_0/64
firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s $wg0networkv6_0/64 ! -d $wg0networkv6_0/64 -j SNAT --to "$hostipv6"
fi

# maybe wrong....
firewall-cmd --zone=trusted --add-forward-port=port=53:proto=tcp:toport=53:toaddr=127.0.0.1
firewall-cmd --zone=trusted --add-forward-port=port=53:proto=udp:toport=53:toaddr=127.0.0.1
                             

firewall-cmd --runtime-to-permanent

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard_ip_forward.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/99-wireguard_ip_forward.conf

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

### setup wireguard keys and configs
mkdir /etc/wireguard/keys
chmod 700 /etc/wireguard/keys

touch /etc/wireguard/keys/server0
chmod 600 /etc/wireguard/keys/server0
wg genkey > /etc/wireguard/keys/server0
wg pubkey < /etc/wireguard/keys/server0 > /etc/wireguard/keys/server0.pub

touch /etc/wireguard/keys/client1
chmod 600 /etc/wireguard/keys/client1
wg genkey > /etc/wireguard/keys/client1
wg pubkey < /etc/wireguard/keys/client1 > /etc/wireguard/keys/client1.pub


echo "[Interface]
Address = $wg0networkv4/24
Address = $wg0networkv6/112
ListenPort = $wg0port
#MTU = $wg0servermtu
PrivateKey = SK01


# client1
[Peer]
PublicKey = PK01
AllowedIPs = ${wg0networkv4}0/32, ${wg0networkv6}0/128
# -end of default clients

" > /etc/wireguard/wg0.conf

sed -i "s@SK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/client1.pub)@" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf

echo "[Interface]
Address = ${wg0networkv4}0/32
Address = ${wg0networkv6}0/128
PrivateKey = CK01
DNS = $wg0networkv4, $wg0networkv6
$wg0mtu
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
$wg0keepalive
" > /etc/wireguard/client1.conf
sed -i "s@CK01@$(cat /etc/wireguard/keys/client1)@" /etc/wireguard/client1.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client1.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client1.conf
chmod 600 /etc/wireguard/client1.conf

clear


exit 1
################################################## 
#################################################

### finish
echo ""
echo ""
echo -e "${YELLOW}QR Code for client1.conf${ENDCOLOR}"
echo ""
qrencode -t ansiutf8 < /etc/wireguard/client1.conf
echo ""
echo -e "${YELLOW}Scan the QR Code with your Wiregard App${ENDCOLOR}"
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf
echo ""
echo -e " ${GREENB}##>${ENDCOLOR}"
echo -e " ${GREENB}##${ENDCOLOR} ${GREEN}Almost done, now you can use the server  ${ENDCOLOR}"
echo -e " ${GREENB}##${ENDCOLOR} ${GRAY}Some additional things you might want to do now:  ${ENDCOLOR}"
echo -e " ${GREENB}##>${ENDCOLOR}"
echo ""
echo -e " ${GRAYB}###>${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${YELLOW}Wireguard options: ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}Add or remove clients with ${YELLOW}./add_client.sh / remove_client.sh${ENDCOLOR}  ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}Backup and restore options with ${YELLOW}./wg_config_backup.sh / ./wg_config_restore.sh${ENDCOLOR}${ENDCOLOR}"
echo -e " ${GRAYB}###${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${YELLOW}pihole options: ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}Make changes, add blocklist, ... over the WebUI  https://10.$wg0networkv4.1/admin  (only over wireguard available)  ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}If needed, change pihole WebUI password with:${ENDCOLOR} ${YELLOW}pihole setpassword${ENDCOLOR}"
echo -e " ${GRAYB}###${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${YELLOW}Nectcloud options: ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}Need a nextcloud instance behind wireguard ? - run ./nextcloud-behind-wireguard.sh ${ENDCOLOR}"
echo -e " ${GRAYB}##${ENDCOLOR} ${GRAY}also only over wireguard available ${ENDCOLOR}"
echo -e " ${GRAYB}##>${ENDCOLOR}"
ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /etc/dnscrypt-proxy/ /root/dnscrypt-proxy_folder
ln -s /var/log /root/system-log_folder

systemctl restart firewalld
exit
