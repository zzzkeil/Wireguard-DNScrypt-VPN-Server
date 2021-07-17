#!/bin/bash
clear
echo " ##############################################################################"
echo " # Wireguard-DNScrypt-VPN-Server uninstaller and back to base_setup           #"
echo " ##############################################################################"
echo ""
echo ""
echo " testing script -  not reday for now "
echo ""
echo ""
echo "To EXIT this script press  [ENTER]"
echo 
read -p "To RUN this script press  [Y]" -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
#
### root check
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

systemctl disable unbound
systemctl disable dnscrypt-proxy.service
systemctl disable wg-quick@wg0.service
systemctl stop unbound
systemctl stop dnscrypt-proxy.service
systemctl stop wg-quick@wg0.service

#ufw delete --- 

crontab -l | grep -v 'generate-domains-blocklist.py'  | crontab  -
crontab -l | grep -v 'domains-allowlist.txt'  | crontab  -
crontab -l | grep -v 'domains-blocklist.conf'  | crontab  -
crontab -l | grep -v 'checkblocklist.sh'  | crontab  -
crontab -l | grep -v 'dnscrypt-proxy.service'  | crontab  -
crontab -l | grep -v 'dnscrypt-proxy-update.sh'  | crontab  -

cp /root/script_backupfiles/ufw.orig /etc/default/ufw 
cp /root/script_backupfiles/before.rules.orig /etc/ufw/before.rules 
cp /root/script_backupfiles/before6.rules.orig /etc/ufw/before6.rules
cp /root/script_backupfiles/sysctl.conf.orig /etc/sysctl.conf
cp /root/script_backupfiles/sysctl.conf.ufw.orig /etc/ufw/sysctl.conf
cp /etc/resolv.conf.orig /etc/resolv.conf

apt remove qrencode unbound unbound-host wireguard-dkms wireguard-tools -y

systemctl enable systemd-resolved
systemctl start systemd-resolved





rm /root/script_backupfiles/ufw.orig
rm /root/script_backupfiles/before.rules.orig
rm /root/script_backupfiles/before6.rules.orig
rm /root/script_backupfiles/sysctl.conf.orig
rm /root/script_backupfiles/sysctl.conf.ufw.orig
rm /root/script_backupfiles/unbound.service.orig
rm /etc/resolv.conf.orig
rm /var/log/dnscrypt-proxy.log
rm /var/log/dnscrypt-proxy-blocked.log
rm -rf /etc/wireguard
rm -rf /etc/dnscrypt-proxy
rm -rf /etc/unbound
rm wireguard-dkms_dnscrypt_blocklist_x86.sh
rm wireguard-dkms_dnscrypt_blocklist_arm64.sh
rm /root/wireguard_folder
rm /root/dnscrypt-proxy_folder
rm /root/system-log_folder
rm /root/Wireguard-DNScrypt-VPN-Server.README
rm add_client.sh
rm remove_client.sh
rm wg_config_backup.sh
rm wg_config_restore.sh

#ufw reload

echo " for now, remove ufw firewall rule manual plz "
ufw status numbered
echo " ufw delete . "
echo " run   ufw relaod   after deleting rules "
