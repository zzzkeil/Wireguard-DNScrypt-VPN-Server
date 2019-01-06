#!/bin/bash
clear
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo " This is a test script for Ubuntu 18.04.1, handle carefully "
echo "  - Install only on a fresh, clean, minimal system "
echo "    -Check my github site for new versions"
echo "      - https://github.com/zzzkeil?tab=repositories "
echo "         - Version 0.1  / 	06.Jan.2019"
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo ""
echo " keil´s VPN - Server setupscript :"
echo " Setup SSH on port 40 with 'better' keys."
echo " Setup UFW, ip6tables and sysctl.conf."
echo " Setup WIREGUARD Server and create one Client config with QR-Code."
echo " Setup Unbound and DNScrypt."
echo ""
echo ""
echo " To EXIT this script press  [ENTER]"
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

if [[ -e /etc/wireguard/wg0.conf ]]; then
     echo
	 echo
     echo "Looks like this script is already installed"
	 echo "This script is only for the first install"
	 echo "Next version have maybe some options like, choose port and create new clients"
	 echo "Check my github site for new versions"
	 echo " - https://github.com/zzzkeil?tab=repositories"
	 echo
	 echo
	 exit 1
fi
	 
#00.Systemupdate
apt update
apt upgrade -y
apt autoremove -y

#01.sshd_config Mod
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

#02. UFW Setup
apt install ufw
ufw allow 40/tcp
ufw allow 14443/udp
ufw allow out 53
ufw deny 22
ufw default deny
cp /etc/default/ufw /etc/default/ufw.orig
cp /etc/ufw/before.rules /etc/ufw/before.rules.orig
cp /etc/ufw/before6.rules /etc/ufw/before6.rules.orig
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before.rules
sed -i '/# End required lines/a -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before.rules
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/ufw/before.rules
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n\n-A POSTROUTING -s fd42:42:42:42::/112 -o eth0 -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before6.rules
sed -i '/# End required lines/a -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before6.rules
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/ufw/before6.rules

#03.sysctl.conf Mod
cp /etc/sysctl.conf /etc/sysctl.conf.orig
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
cp /etc/ufw/sysctl.conf /etc/ufw/sysctl.conf.orig
sed -i 's@#net/ipv4/ip_forward=1@net/ipv4/ip_forward=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/default/forwarding=1@net/ipv6/conf/default/forwarding=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/all/forwarding=1@net/ipv6/conf/all/forwarding=1@g' /etc/ufw/sysctl.conf


#04. apt install 
add-apt-repository ppa:wireguard/wireguard -y
apt update
apt install linux-headers-$(uname -r) wireguard qrencode unbound unbound-host -y 



#05. setup wireguard keys
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

#06. setup wireguard server config
echo "[Interface]
Address = 10.8.0.1/24
Address = fd42:42:42:42::1/112
ListenPort = 14443
PrivateKey = PK01

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = PK02
AllowedIPs = 10.8.0.2/32, fd42:42:42:42::2/128" > /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK02@$(cat /etc/wireguard/keys/client0.pub)@" /etc/wireguard/wg0.conf
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf

#07. setup wireguard client config
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


#08. Unbound
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

#09. DNSCrypt config
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
#blacklist_file = 'blacklist.txt'

[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
  cache_file = 'public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''

[static]
" > /etc/dnscrypt-proxy/dnscrypt-proxy.toml

#90 systemctl
systemctl stop systemd-resolved
systemctl disable systemd-resolved
cp /etc/resolv.conf /etc/resolv.conf.orig
rm -f /etc/resolv.conf
systemctl enable unbound
ufw --force enable
ufw reload
systemctl restart sshd.service
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

#solve issuses with unbound after reboot (no dns for wireguard client)
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


#100 finish
echo ""
echo ""
echo " QR Code from client0.conf / for your mobile client "
qrencode -t ansiutf8 < /etc/wireguard/client0.conf
echo "Scan the QR Code with your Wiregard App,"
echo "to import the config on your phone"
echo ""
echo " Remember to change your ssh client port to 40 "
echo " Reboot your system now or later " 



