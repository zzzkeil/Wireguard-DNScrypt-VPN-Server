#!/bin/bash


#test mer mal 
main_menu() {
    while true; do
        CHOICE=$(whiptail --title "After setup options" --menu "Choose an option" 15 60 4 \
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
    CHOICE=$(whiptail --title "Wireguard options" --menu "Choose" 15 60 4 \
    "1" "Add wireguard client" \
    "2" "Remove wireguard client" \
    "3" "Backup wireguard config" \
    "4" "Restore wireguard config" \
    "5" "Restore wireguard config" \
    "6" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        6) return;;
    esac
}

pihole_menu() {
    CHOICE=$(whiptail --title "Pihole options" --menu "Choose" 15 60 4 \
    "1" "Show WebUI URL" \
    "2" "Change WebUI password" \
    "3" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ;;
        2) ;;
        3) return;;
    esac
}

nextcloud_menu() {
    CHOICE=$(whiptail --title "Nextcloud options" --menu "Choose a setting" 15 60 4 \
    "1" "Install Nextcloud behind wireguard" \
    "2" "Back to Main Menu" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) ;;
        2) return;;
    esac
}


# Start the menu system
main_menu
