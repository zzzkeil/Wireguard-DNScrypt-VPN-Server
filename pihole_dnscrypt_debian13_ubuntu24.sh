#!/bin/bash

msghi="This script installs and configure wireguard, dnscrypt and pihole. \n
With wireguard, you get a secure connection (VPN) and access to www :) \\n
With DNScrypt your requests are anonymized / encrypted on your server \n
With Pi-hole AD´s and ThreatIntelligenceFeeds and ... get BLOCKED \n
With access to the Pi-hole WebUI (only over wireguard), you can customize everything \n\n
More options / infos will be showed after the install is complete \n
Nextcloud can be installed also, with access only over wireguard \n\n
Infos @ https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server \n
Version 2025.08.xx \n\n
Run script now ?"

if whiptail --title "Hi, lets start" --yesno "$msghi" 25 90; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, no install right now. Have a nice day." 15 80
exit 1
fi  

### root check
if [[ "$EUID" -ne 0 ]]; then
whiptail --title "Aborted" --msgbox "Sorry, you need to run this as root!" 15 80
exit 1
fi

### OS check
. /etc/os-release
if [[ "$ID" = 'debian' ]]; then
 if [[ "$VERSION_ID" = '13' ]]; then
 systemos=debian
 fi
fi

if [[ "$ID" = 'ubuntu' ]]; then
 if [[ "$VERSION_ID" = '24.04' ]]; then
 systemos=ubuntu
 fi
fi

if [[ "$systemos" = '' ]]; then
whiptail --title "Aborted" --msgbox "This script is only for Debian 13 and Ubuntu 24.04 !" 15 80
exit 1
fi

### Architecture check for dnsscrpt 
ARCH=$(uname -m)
if [[ "$ARCH" == x86_64* ]]; then
  dnsscrpt_arch=x86_64
elif [[ "$ARCH" == aarch64* ]]; then
  dnsscrpt_arch=arm64
else
whiptail --title "Aborted" --msgbox "This script is only for x86_64 or ARM64  Architecture !" 15 80
exit 1
fi

### base_setup check
if [[ -e /root/base_setup.README ]]; then
echo ""
else
wget -O  setup_base.sh https://raw.githubusercontent.com/zzzkeil/base_setups/refs/heads/master/setup_base.sh
chmod +x setup_base.sh
echo  "tempfile" > /root/reminderfile.tmp

msgbase="Some system requirements and packages are missing. \n
No problem, another script from me take care of that. \n
Run the setup_base.sh script and reboot after. \n
After a reboot you will be automatically coming back here to continue. \n
If not, just run this script again !! \n\n
cu later...\n"
OPTION=$(whiptail --title "System requirements" --menu "$msgbase" 15 80 3 \
"1" "Run /root/setup_base.sh" \
"2" "Exit" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus != 0 ]; then
    whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
    exit
fi

case $OPTION in
    1)
        ./setup_base.sh
        ;;
    2)
        whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
        ;;
    *)
        whiptail --title "?" --msgbox "Invalid option.......\n" 15 80
        ;;
esac
exit 1
fi

### already installed ??

# function mainmenü
main_menu() {
    while true; do
        CHOICE=$(whiptail --title "After setup options" --menu "Choose an option" 20 80 4 \
        "1" "Wireguard options" \
        "2" "Pihole options" \
        "3" "Nextcloud options" \
        "4" "Exit" 3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
            break
        fi

        case $CHOICE in
            1) wireguard_menu ;;
            2) pihole_menu ;;
            3) nextcloud_menu ;;
            4) break ;;
        esac
    done
}

wireguard_menu() {
    CHOICE=$(whiptail --title "Wireguard options" --menu "Choose" 20 60 6 \
    "1" "Add wireguard client" \
    "2" "Remove wireguard client" \
    "3" "Backup wireguard config" \
    "4" "Restore wireguard config" \
    "5" "Show QR Code for clients" \
    "6" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ./add_client.sh ;;
        2) ./remove_client.sh ;;
        3) ./wg_config_backup.sh ;;
        4) ./wg_config_restore.sh ;;
        5)  wgqrcodes_menu;;
        6) return ;;
    esac
}

wgqrcodes_menu() {
wgqrcodes="/etc/wireguard/wg0.conf"
clients=$(grep "# Name = " "$wgqrcodes" | awk '{print substr($0, 9)}')
menu_items=()
while read -r name; do
    menu_items+=("$name" "")
done <<< "$clients"
clientname=$(whiptail --title "Shwo QRCode for WireGuard Client" \
    --menu "Select a client:" 20 60 10 \
    "${menu_items[@]}" \
    3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    whiptail --msgbox "Cancelled by user." 8 40
    exit 0
fi
qrencode -t ansiutf8 < /etc/wireguard/$clientname.conf ; read -n 1 -s -r -p "Press any key to continue..." 
}

pihole_menu() {
    CHOICE=$(whiptail --title "Pihole options" --menu "Choose" 20 60 4 \
    "1" "Show WebUI URL" \
    "2" "Change WebUI password" \
    "3" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
		   piurl=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
	       fi
		   whiptail --title "Pihole URL" --msgbox "https://$piurl:8443/admin" 20 80 ;;
        2) while true; do
    whiptail --title "Pi-hole Password Setup" --infobox --nocancel "Please enter a password for your Pi-hole admin interface." 15 80
    pihole_password=$(whiptail --title "Pi-hole Password" --inputbox --nocancel "Enter your Pi-hole admin password\nmin. 8 characters" 15 80 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
       echo ""
    fi
    if [ ${#pihole_password} -ge 8 ]; then
	whiptail --title "Password Set" --msgbox "Password has been set successfully!" 15 60
        pihole setpassword $pihole_password
        break 
    else
        whiptail --title "Invalid Password" --msgbox "Password must be at least 8 characters long. Please try again." 15 60
    fi
done ;;
        3) return ;;
    esac
}

nextcloud_menu() {
    CHOICE=$(whiptail --title "Nextcloud options" --menu "Choose a setting" 20 80 4 \
    "1" "Install Nextcloud behind wireguard" \
    "2" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ./nextcloud-behind-wireguard.sh;;
        2) return ;;
    esac
}




if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
msginst="Looks like this script is already installed\n
You will see the main menu now\n\n"
whiptail --title "already installed" --msgbox "$msginst" 15 80
main_menu
exit 0
fi


### wireguard options with input checks
    ### lets take care of your ssh port 
ssh_port=$(grep -i "^Port" /etc/ssh/sshd_config | awk '{print $2}')
is_valid_port() {
    local wgport="$1"
    if [[ "$wgport" =~ ^[0-9]+$ ]] && [ "$wgport" -ge 1025 ] && [ "$wgport" -le 65535 ] && [ "$wgport" -ne 5335 ] && [ "$wgport" -ne 8443 ] && [ "$wgport" -ne $ssh_port ]; then
        return 0
    else
        return 1
    fi
}

while true; do
    wg0port=$(whiptail --title "Wireguard Port Settings" --inputbox "Choose a free port 1025-65535\nDo not use port $ssh_port, 5335, 8443\nDo not use a used port!\nTo list all currently activ ports, cancel now and you see a list\nThen start this script again" 15 80 "54234" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        if is_valid_port "$wg0port"; then
            break
        else
            whiptail --title "Invalid Port" --msgbox "Invalid port number. Please enter a port number between 1025 and 65535. Do not use port $ssh_port, 5335, 8443" 15 80
        fi
    else
	whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
    clear
	echo "Here is your list of currently open ports:"
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
        whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
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
        whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
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
        whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
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
        whiptail --title "Aborted" --msgbox "Ok, cancel. No changes to system was made.\n" 15 80
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

echo 'Dpkg::Progress-Fancy "1";' | sudo tee /etc/apt/apt.conf.d/99progressbar

update_upgrade_with_gauge() {
    {
        echo 10
        echo "Starting apt-get update..."
        apt-get update -y &> /dev/null
        if [ $? -ne 0 ]; then
            echo 100
            echo "Error: apt-get update failed."
            exit 1
        fi

        echo 50
        echo "Starting apt-get upgrade..."
        apt-get upgrade -y &> /dev/null
        if [ $? -ne 0 ]; then
            echo 100
            echo "Error: apt-get upgrade failed."
            exit 1
        fi

        echo 100
        echo "Update and Upgrade completed successfully."
    } | whiptail --title "System Update and Upgrade" --gauge "Please wait while updating and upgrading the system..." 15 80 0

    if [ $? -eq 0 ]; then
       echo ""
    else
        whiptail --title "Error" --msgbox "The update/upgrade process was interrupted." 15 80
    fi
}

update_upgrade_with_gauge

packages1=("qrencode" "python-is-python3" "curl" "linux-headers-$(uname -r)" "sqlite3" "resolvconf")
packages2=("wireguard" "wireguard-tools")
install_multiple_packages_with_gauge1() {
    total=${#packages1[@]}
    step=0

    {
        for pkg in "${packages1[@]}"; do
            percent=$(( (step * 100) / total ))
            echo $percent
            echo "Installing package: $pkg..."
            sudo apt-get install -y "$pkg" &> /dev/null
            if [ $? -ne 0 ]; then
                echo 100
                echo "Error: Installation of package $pkg failed."
                exit 1
            fi
            step=$((step + 1))
        done
        echo 100
        echo "All packages installed successfully."
    } | whiptail --title "Installing needed OS Packages" --gauge "Please wait while installing packages...\nqrencode, python-is-python3, curl\nlinux-headers-......, sqlite3, resolvconf" 15 80 0

    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "Error" --msgbox "Installation process interrupted or failed." 15 80
		exit 1
    fi
}

install_multiple_packages_with_gauge1
install_multiple_packages_with_gauge2() {
    total=${#packages2[@]}
    step=0

    {
        for pkg in "${packages2[@]}"; do
            percent=$(( (step * 100) / total ))
            echo $percent
            echo "Installing package: $pkg..."
            sudo apt-get install -y "$pkg" &> /dev/null
            if [ $? -ne 0 ]; then
                echo 100
                echo "Error: Installation of package $pkg failed."
                exit 1
            fi
            step=$((step + 1))
        done
        echo 100
        echo "All packages installed successfully."
    } | whiptail --title "Installing wireguard" --gauge "Please wait while installing wireguard, wireguard-tools..." 15 80 0

    if [ $? -eq 0 ]; then
        echo ""
    else
        whiptail --title "Error" --msgbox "Installation process interrupted or failed." 15 80
		exit 1
    fi
}

install_multiple_packages_with_gauge2

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

chmod +x add_client.sh
chmod +x remove_client.sh
chmod +x wg_config_backup.sh
chmod +x wg_config_restore.sh
chmod +x uninstaller_back_to_base.sh
chmod +x nextcloud-behind-wireguard.sh

mkdir /etc/dnscrypt-proxy/
mv dnscrypt-proxy-pihole.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
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

/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start

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
    whiptail --title "Pi-hole Password Setup" --infobox --nocancel "Please enter a password for your Pi-hole admin interface." 15 80
    pihole_password=$(whiptail --title "Pi-hole Password" --inputbox --nocancel "Enter your Pi-hole admin password\nmin. 8 characters" 15 80 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
       echo ""
    fi
    if [ ${#pihole_password} -ge 8 ]; then
	whiptail --title "Password Set" --msgbox "Password has been set successfully!" 15 60
        pihole setpassword $pihole_password
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
MTU = $wg0mtu
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = $allownet
PersistentKeepalive = $wg0keepalive
" > /etc/wireguard/client1.conf
sed -i "s@CK01@$(cat /etc/wireguard/keys/client1)@" /etc/wireguard/client1.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client1.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client1.conf
chmod 600 /etc/wireguard/client1.conf
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf


systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /etc/dnscrypt-proxy/ /root/dnscrypt-proxy_folder
ln -s /var/log /root/system-log_folder
systemctl restart firewalld
rm /root/reminderfile.tmp


main_menu

echo "To see the options again, the script again"

exit
