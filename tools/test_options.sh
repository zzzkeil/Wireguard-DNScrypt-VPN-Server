#!/bin/bash


#test mer mal 
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
            3) break ;;
        esac
    done
}

wireguard_menu() {
    CHOICE=$(whiptail --title "Wireguard options" --menu "Choose" 20 60 4 \
    "1" "Add wireguard client" \
    "2" "Remove wireguard client" \
    "3" "Backup wireguard config" \
    "4" "Restore wireguard config" \
    "5" "Show QR Code for client 1" \
    "6" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ./add_client.sh ;;
        2) ./remove_client.sh ;;
        3) ./wg_config_backup.sh ;;
        4) ./wg_config_restore.sh ;;
        5) qrencode -t ansiutf8 < /etc/wireguard/client1.conf ;;
        6) return ;;
    esac
}

pihole_menu() {
    CHOICE=$(whiptail --title "Pihole options" --menu "Choose" 20 60 4 \
    "1" "Show WebUI URL" \
    "2" "Change WebUI password" \
    "3" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) whiptail --title "Pihole URL" --msgbox "https://$wg0networkv4:8443/admin" 20 80 ;;
        2) while true; do
    whiptail --title "Pi-hole Password Setup" --infobox --nocancel "Please enter a password for your Pi-hole admin interface." 15 80
    pihole_password=$(whiptail --title "Pi-hole Password" --inputbox --nocancel "Enter your Pi-hole admin password\nmin. 8 characters" 15 80 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
       echo ""
    fi
    if [ ${#pihole_password} -ge 8 ]; then
	whiptail --title "Password Set" --msgbox "Password has been set successfully!" 15 60
        break 
    else
        whiptail --title "Invalid Password" --msgbox "Password must be at least 8 characters long. Please try again." 15 60
    fi
done;;
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


# Start the menu system
main_menu
