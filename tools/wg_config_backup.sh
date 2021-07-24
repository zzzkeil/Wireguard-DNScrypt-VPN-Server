#!/bin/bash
clear
echo " this script backup yours wireguard server config "
echo " in case if you need to reinstall your server, but not want to reconfigure your all clients"
echo "."
echo "."
echo "."
tar -cf  /root/backup_wg_config.tar /etc/wireguard
tar --append --file=/root/backup_wg_config.tar /etc/ufw/before.rules
tar --append --file=/root/backup_wg_config.tar /etc/ufw/before6.rules
tar --append --file=/root/backup_wg_config.tar /etc/unbound/unbound.conf
echo "."
echo "."
echo "."
echo " done backupfile is /root/backup_wg_config.tar.gz "
echo " download / copy / save the file to your needs "
echo " to restore place the file here /root/backup_wg_config.tar.gz and run ./wg_config_restore.sh "
