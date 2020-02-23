#!/bin/bash
clear
echo " Just 4 testing now "
echo " maybe dont work "
echo " be carefull"
echo "."
echo "."
echo "."
echo "."
###
echo "DNScrypt version"
echo "Choose the version of DNScrypt you want"
read -p "DNScrypt version: " -e -i 2.0.39 dnscryptver
echo "------"
wget -O /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz https://github.com/jedisct1/dnscrypt-proxy/releases/download/$dnscryptver/dnscrypt-proxy-linux_x86_64-$dnscryptver.tar.gz
#
/etc/dnscrypt-proxy/dnscrypt-proxy -service stop
systemctl stop unbound
#
tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
#
/etc/dnscrypt-proxy/dnscrypt-proxy -service start
systemctl start unbound
#
echo "finished"
