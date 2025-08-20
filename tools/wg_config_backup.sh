#!/bin/bash
if whiptail --title "Backup wireguard config" --yesno "This script backup yours wireguard server config, \nif you need to reinstall your server, but not want to reconfigure your all clients\n\nRun script now ?\n" 15 80; then
echo ""
else
whiptail --title "Aborted" --msgbox "Ok, not now. cu have a nice day." 15 90
exit 0
fi   
tar -cf  /root/backup_wg_config.tar /etc/wireguard
tar --append --file=/root/backup_wg_config.tar /root/Wireguard-DNScrypt-VPN-Server.README
tar --append --file=/root/backup_wg_config.tar /etc/dnscrypt-proxy/allowed-names.txt
whiptail --title "Done" --msgbox "Done backupfile is /root/backup_wg_config.tar.gz\nDownload / copy / save the file to your needs\nto restore place the file here /root/backup_wg_config.tar.gz\n and run ./wg_config_restore.sh" 15 90
exit 0
