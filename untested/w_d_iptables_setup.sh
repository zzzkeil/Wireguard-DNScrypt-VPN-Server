#!/bin/bash
clear
echo " ####################################################################"
echo " #  This script is only for Ubuntu 18.04.1                          #"
echo " #  Script is in beta status, handle carefully                      #"
echo " #  Only testet, on a fresh, clean, minimal system                  #"
echo " #  Check my github site for new versions                           #"
echo " #  https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server        #"
echo " #  UNTESTED VERSION - - JUST FOR TESTING                           #"
echo " ####################################################################"
echo " #                                                                  #"
echo " #         !!! READ THIS  BEFOR YOU RUN THIS SCRIPT !!!             #"
echo " #         !!!  SCRIPT IS NOT FINISHED; DO NOT RUN  !!!             #"
echo " #                                                                  #"
echo " ####################################################################"
echo " #  zzzkeil´s Wireguard-DNScrypt-VPN-Server setup:                  #"
echo " #  Setup SSH on port 40 with 'better' keys.                        #"
echo " #  Setup iptabels, ip6tables and sysctl.conf.                      #"
echo " #  Setup WIREGUARD Server - create a Client config with QR-Code.   #"
echo " #  Setup Unbound and DNScrypt with a Blocklist (ADs/Maleware/...)  #"
echo " ####################################################################"
echo ""
echo ""
echo "To EXIT this script press  [ENTER]"
echo " ###########>> SCRIPT IS NOT FINISHED; DO NOT RUN"
echo 
read -p "To RUN this script press  [Y]" -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
     echo
	 echo
         echo "Looks like this script is already installed"
	 echo "This script is only for the first install"
	 echo "Read the instructions in this file: "
	 echo "/root/Wireguard-DNScrypt-VPN-Server.README"
	 echo "Next version have maybe some options like, "
	 echo "choose port, create new clients, remove all"
	 echo "Check my github site for new versions"
	 echo "https://github.com/zzzkeil/Wireguard-DNScrypt-VPN-Server"
	 echo
	 echo
	 exit 1
fi
	 
#Step 01 - Systemupdate and install needed stuff
apt update && apt upgrade -y && apt autoremove -y
add-apt-repository ppa:wireguard/wireguard -y
apt update
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt install linux-headers-$(uname -r) wireguard qrencode unbound unbound-host python iptables-persistent -y 



#Step 02 - Setup SSH
ssh-keygen -f /etc/ssh/key1rsa -t rsa -b 4096 -N ""
ssh-keygen -f /etc/ssh/key2ecdsa -t ecdsa -b 521 -N ""
ssh-keygen -f /etc/ssh/key3ed25519 -t ed25519 -N ""
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
echo "Port 40
HostKey /etc/ssh/key1rsa
HostKey /etc/ssh/key2ecdsa
HostKey /etc/ssh/key3ed25519
PermitRootLogin yes
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config




#Step 04 - Setup sysctl.conf
cp /etc/sysctl.conf /etc/sysctl.conf.orig
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf



#Step 05 - Setup wireguard keys
mkdir /etc/wireguard/keys
chmod 700 /etc/wireguard/keys
touch /etc/wireguard/keys/server0
chmod 600 /etc/wireguard/keys/server0
wg genkey > /etc/wireguard/keys/server0
wg pubkey < /etc/wireguard/keys/server0 > /etc/wireguard/keys/server0.pub
touch /etc/wireguard/keys/client0
chmod 600 /etc/wireguard/keys/client0
wg genkey > /etc/wireguard/keys/client0
wg pubkey < /etc/wireguard/keys/client0 > /etc/wireguard/keys/client0.pub



#Step 06 - Setup wireguard server config
echo "[Interface]
Address = 10.8.0.1/24
Address = fd42:42:42:42::1/112
ListenPort = 14443
PrivateKey = PK01

[Peer]
PublicKey = PK02
AllowedIPs = 10.8.0.2/32, fd42:42:42:42::2/128" > /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK02@$(cat /etc/wireguard/keys/client0.pub)@" /etc/wireguard/wg0.conf
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf



#Step 07 - Setup wireguard client config
echo "[Interface]
Address = 10.8.0.2/32
Address = fd42:42:42:42::2/128
PrivateKey = PK03
DNS = 10.8.0.1, fd42:42:42:42::1

[Peer]
Endpoint = IP01:14443
PublicKey = PK04
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client0.conf
sed -i "s@PK03@$(cat /etc/wireguard/keys/client0)@" /etc/wireguard/client0.conf
sed -i "s@PK04@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client0.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client0.conf
chmod 600 /etc/wireguard/client0.conf



#Step 08 - Setup unbound
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
echo '
server:
num-threads: 1
verbosity: 1
root-hints: "/var/lib/unbound/root.hints"
interface: 0.0.0.0
interface: ::0
max-udp-size: 3072
access-control: 0.0.0.0/0                 refuse
access-control: 127.0.0.0/24                 allow
access-control: 10.8.0.0/24         allow
access-control: ::1                   allow
access-control: fd42:42:42:42::1/64         allow
private-address: 10.8.0.0/24 
private-address: fd42:42:42:42::1/64
hide-identity: yes
hide-version: yes
harden-glue: yes
harden-dnssec-stripped: yes
harden-referral-path: yes
unwanted-reply-threshold: 10000000
val-log-level: 1
cache-min-ttl: 1800 
cache-max-ttl: 14400
prefetch: yes
prefetch-key: yes
do-not-query-localhost: no

 forward-zone:
  name: "."
      forward-addr: 127.0.0.1@5353
' >> /etc/unbound/unbound.conf
chown -R unbound:unbound /var/lib/unbound



#Step 09 - Setup DNSCrypt
mkdir /etc/dnscrypt-proxy/
wget -O /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz https://github.com/jedisct1/dnscrypt-proxy/releases/download/2.0.19/dnscrypt-proxy-linux_x86_64-2.0.19.tar.gz
tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
mv -f /etc/dnscrypt-proxy/linux-x86_64/* /etc/dnscrypt-proxy/
#
cp /etc/dnscrypt-proxy/example-blacklist.txt /etc/dnscrypt-proxy/blacklist.txt 
#
echo "listen_addresses = ['127.0.0.1:5353']
#server_names = ['trashvpn.de', 'zeroaim.de-ipv6', 'doh-crypto-sx', 'cloudflare-ipv6', 'dnscrypt.eu-dk', 'dnscrypt.uk-ipv6', 'securedns-doh', 'scaleway-fr']
max_clients = 250
ipv4_servers = true
ipv6_servers = true
dnscrypt_servers = true
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = true
force_tcp = false
timeout = 2000
lb_strategy = 'p2'
log_level = 2
log_file = '/var/log/dnscrypt-proxy.log'
cert_refresh_delay = 33
fallback_resolver = '1.1.1.1:53'
ignore_system_dns = false
log_files_max_size = 1
log_files_max_age = 1
log_files_max_backups = 7
block_ipv6 = false
cache = true
cache_size = 512
cache_min_ttl = 600
cache_max_ttl = 1200
cache_neg_ttl = 60

[blacklist]
blacklist_file = 'blacklist.txt'

[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
  cache_file = 'public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''

[static]
" > /etc/dnscrypt-proxy/dnscrypt-proxy.toml

#Step 10 - Setup Blacklist >
mkdir /etc/dnscrypt-proxy/utils/
mkdir /etc/dnscrypt-proxy/utils/generate-domains-blacklists/
#curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/domains-blacklist-ultimate.conf
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-blacklist.conf
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-time-restricted.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-time-restricted.txt
echo "" > /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-whitelist.txt
#curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-whitelist.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-whitelist.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/generate-domains-blacklist.py
chmod +x /etc/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py
cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/
./generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt
cd
echo "20 13 * * * cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/ && /usr/bin/python generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt" >> blacklistcron
crontab blacklistcron
rm blacklistcron



#Step 90 - Setup systemctl
systemctl stop systemd-resolved
systemctl disable systemd-resolved
cp /etc/resolv.conf /etc/resolv.conf.orig
rm -f /etc/resolv.conf
systemctl enable unbound
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
##
#solve issuses with unbound after reboot (no dns for wireguard client)
##
cp /etc/systemd/system/multi-user.target.wants/unbound.service /etc/unbound/unbound.service.orig
systemctl disable unbound
echo "[Unit]
Description=Unbound DNS server
Documentation=man:unbound(8)
After=wg-quick@wg0.service


[Service]
Type=notify
Restart=on-failure
EnvironmentFile=-/etc/default/unbound
ExecStartPre=-/usr/lib/unbound/package-helper chroot_setup
ExecStartPre=-/usr/lib/unbound/package-helper root_trust_anchor_update
ExecStart=/usr/sbin/unbound -d $DAEMON_OPTS
ExecReload=/usr/sbin/unbound-control reload
PIDFile=/run/unbound.pid

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/unbound.service
systemctl enable unbound
systemctl restart unbound

/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start

#Step 91 - Set file for install check (see line 34)
echo "Wireguard-DNScrypt-VPN-Server installed,
please remove all files/configs carefully,
before you delete this file and run the script again
" > /root/Wireguard-DNScrypt-VPN-Server.README


#Step 100 - finish :)
echo ""
echo ""
echo " QR Code from client0.conf / for your mobile client "
qrencode -t ansiutf8 < /etc/wireguard/client0.conf
echo "Scan the QR Code with your Wiregard App,"
echo "to import the config on your phone"
echo ""
echo " Remember to change your ssh client port to 40 "
echo " Reboot your system now or later " 
systemctl restart sshd.service
# Here i´m working now ----  Not finished !!  caution learning by doing !!
#Step 03 - Setup iptabels
#mv /etc/iptables/rules.v4 /etc/iptables/rules.v4.orig
#mv /etc/iptables/rules.v6 /etc/iptables/rules.v6.orig
#ipv4
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 40 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -P INPUT DROP
#iptables -A INPUT -j DROP
#
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p tcp --dport 40 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 14443 -m conntrack --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -P OUTPUT DROP
#iptables -A OUTPUT -j DROP
iptables-save > /etc/iptables/rules.v4
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/iptables/rules.v4

#ipv6
ip6tables -A INPUT -i lo -p all -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport 40 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -s fd42:42:42:42::/112 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -s fd42:42:42:42::/112 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -t nat -A POSTROUTING -s fd42:42:42:42::/112 -o eth0 -j MASQUERADE
ip6tables -P INPUT DROP
#ip6tables -A INPUT -j DROP
#
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 40 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 80 -m staconntrackte --ctstate NEW -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A OUTPUT -p udp -m udp --dport 14443 -m ctstate --state NEW,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -P OUTPUT DROP
#ip6tables -A OUTPUT -j DROP
iptables-save > /etc/iptables/rules.v6
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/iptables/rules.v6
systemctl enable netfilter-persistent
netfilter-persistent save
