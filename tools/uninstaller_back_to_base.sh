#!/bin/bash
clear
echo " ###############################################################################"
echo " # Wireguard-DNScrypt-VPN-Server uninstaller and back to base_setup            #"
echo " # if needed create a backup > ./wg_config_backup.sh befor deleting everything #"
echo " ###############################################################################"
echo ""
echo ""
echo ""
echo ""
echo "                      To EXIT this script press  [ENTER]"
echo 
read -p "                   To RUN this script press  [Y]" -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
clear
echo " ####################################"
echo " # Last chance  to get out here :)  #"
echo " ####################################"
echo ""
echo ""
echo ""
echo ""
echo "      Press [ENTER] to abort"
echo 
read -p "   Press [Y] to delete" -n 1 -r
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


systemctl disable dnscrypt-proxy.service
systemctl disable wg-quick@wg0.service
systemctl stop dnscrypt-proxy.service
systemctl stop wg-quick@wg0.service


crontab -l | grep -v 'generate-domains-blocklist.py'  | crontab  -
crontab -l | grep -v 'domains-allowlist.txt'  | crontab  -
crontab -l | grep -v 'domains-blocklist.conf'  | crontab  -
crontab -l | grep -v 'checkblocklist.sh'  | crontab  -
crontab -l | grep -v 'dnscrypt-proxy.service'  | crontab  -
crontab -l | grep -v 'dnscrypt-proxy-update.sh'  | crontab  -


cp /root/script_backupfiles/sysctl.conf.orig /etc/sysctl.conf
cp /etc/resolv.conf.orig /etc/resolv.conf


. /etc/os-release
if [[ "$ID" = 'debian' ]]; then
   systemos=debian
fi


if [[ "$ID" = 'fedora' ]]; then
   systemos=fedora
fi


if [[ "$systemos" = 'debian' ]]; then
apt remove qrencode python-is-python3 curl linux-headers-$(uname -r) wireguard wireguard-tools -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf remove qrencode python-is-python3 curl cronie cronie-anacron wireguard-tools -y
fi


#################### remove fw settings todo ?

hostipv4=$(hostname -I | awk '{print $1}')
hostipv6=$(hostname -I | awk '{print $2}')
wg0networkv4=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0networkv6=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)
wg0port=$(sed -n 12p /root/Wireguard-DNScrypt-VPN-Server.README)


firewall-cmd --zone=public --remove-port="$wg0port"/udp

firewall-cmd --zone=trusted --remove-source=10.$wg0networkv4.0/24
firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.$wg0networkv4.0/24 ! -d 10.$wg0networkv4.0/24 -j SNAT --to "$hostipv4"

if [[ -n "$hostipv6" ]]; then
firewall-cmd --zone=trusted --remove-source=fd42:$wg0networkv6::/64
firewall-cmd --direct --remove-rule ipv6 nat POSTROUTING 0 -s fd42:$wg0networkv6::/64 ! -d fd42:$wg0networkv6::/64 -j SNAT --to "$hostipv6"
fi

firewall-cmd --zone=trusted --remove-forward-port=port=53:proto=tcp:toport=53:toaddr=127.0.0.1
firewall-cmd --zone=trusted --remove-forward-port=port=53:proto=udp:toport=53:toaddr=127.0.0.1



rm /etc/sysctl.d/99-wireguard_ip_forward.conf
echo 0 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv6/conf/all/forwarding


systemctl enable systemd-resolved
systemctl start systemd-resolved

rm /root/script_backupfiles/sysctl.conf.orig
rm /etc/resolv.conf.orig
rm /var/log/dnscrypt-proxy.log
rm /var/log/dnscrypt-proxy-blocked.log
rm /etc/systemd/system/dnscrypt-proxy.service
rm -rf /etc/wireguard
rm -rf /etc/dnscrypt-proxy
rm -rf /etc/unbound
rm wireguard_dnscrypt_setup.sh
rm /root/wireguard_folder
rm /root/dnscrypt-proxy_folder
rm /root/system-log_folder
rm /root/Wireguard-DNScrypt-VPN-Server.README
rm add_client.sh
rm remove_client.sh
rm wg_config_backup.sh
rm wg_config_restore.sh

firewall-cmd --runtime-to-permanent
firewall-cmd --reload

echo "reboot, soon as possible"
