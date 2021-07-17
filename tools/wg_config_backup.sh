#!/bin/bash
clear
echo " this script backup yours wireguard server config "
echo " in case if you need to reinstall your server, but not want to reconfigure your all clients"
echo " "
echo " work in progess "
echo "."
echo "."
echo "."
tar -czf  /root/backup_wg_config.tar.gz /etc/wireguard
echo "."
echo "."
echo "."
echo " to restore run ./wg_config_restore.sh "

