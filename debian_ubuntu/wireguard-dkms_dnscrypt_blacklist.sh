#!/bin/bash
clear
echo " READ ME NOW  -  Befor you run this script "
echo ""
echo " You need to run my base_setup script first!"
echo " https://github.com/zzzkeil/base_setups/blob/master/base_setup.sh"
echo ""
echo " This script will not work without my base_setup!"
echo ""
echo ""
echo ""
echo ""

if [[ -e /root/base_setup.README ]]; then
     echo "base_setup script installed - OK"
	 else
	 echo "base_setup script not installed - download start"
	 echo ""
	 echo ""
	 wget -O  base_setup.sh https://raw.githubusercontent.com/zzzkeil/base_setups/master/base_setup.sh
     chmod +x base_setup.sh
	 echo ""
	 echo ""
     echo " Now you have to run ./base_setup.sh and reboot, after that you can run this script again."
	 echo ""
	 echo ""
	 exit 1
fi

echo "To EXIT this script press  [ENTER]"
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

if [[ -e /etc/debian_version ]]; then
      echo "Debian Distribution"
      else
      echo "This is not a Debian Distribution."
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

####
mkdir /root/script_backupfiles/
echo "Step 01 - Your options"
echo
echo "Make your Port settings now:"
echo "------------------------------------------------------------"
read -p "Choose your Wireguard Port: " -e -i 51820 wg0port
echo "------------------------------------------------------------"
echo
echo "Ok let´s go"
echo

####
	 
echo "Step 02 - Systemupdate and Downloads" 
echo
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
if [[ "$VERSION_ID" = 'VERSION_ID="10"' ]]; then
	echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
        printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable
fi

if [[ "$VERSION_ID" = 'VERSION_ID="18.04"' ]]; then
    add-apt-repository ppa:wireguard/wireguard
fi


apt update && apt upgrade -y && apt autoremove -y
apt install qrencode unbound unbound-host python curl -y 
apt install wireguard-dkms wireguard-tools -y

####

echo "Step 04 - Setup UFW"
echo
inet=$(ip route show default | awk '/default/ {print $5}')
ufw allow $wg0port/udp
cp /etc/default/ufw /root/script_backupfiles/ufw.orig
cp /etc/ufw/before.rules /root/script_backupfiles/before.rules.orig
cp /etc/ufw/before6.rules /root/script_backupfiles/before6.rules.orig
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n-A POSTROUTING -s 10.8.0.0/24 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before.rules
sed -i '/# End required lines/a \\n-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/a \\n# allow outbound icmp\n-A ufw-before-output -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT\n-A ufw-before-output -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT\n' /etc/ufw/before.rules
sed -i "1i# START WIREGUARD RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from WIREGUARD client \n\n-A POSTROUTING -s fd42:42:42:42::/112 -o $inet -j MASQUERADE\nCOMMIT\n# END WIREGUARD RULES\n" /etc/ufw/before6.rules
sed -i '/# End required lines/a \\n-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p udp -m udp --dport 14443 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A INPUT -s fd42:42:42:42::1/64 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT\n-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT' /etc/ufw/before6.rules

####

echo "Step 05 - Setup sysctl.conf"
echo
cp /etc/sysctl.conf /root/script_backupfiles/sysctl.conf.orig
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
cp /etc/ufw/sysctl.conf /root/script_backupfiles/sysctl.conf.ufw.orig
sed -i 's@#net/ipv4/ip_forward=1@net/ipv4/ip_forward=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/default/forwarding=1@net/ipv6/conf/default/forwarding=1@g' /etc/ufw/sysctl.conf
sed -i 's@#net/ipv6/conf/all/forwarding=1@net/ipv6/conf/all/forwarding=1@g' /etc/ufw/sysctl.conf



####

echo "Step 06 - Setup wireguard keys"
echo
mkdir /etc/wireguard/keys
chmod 700 /etc/wireguard/keys

touch /etc/wireguard/keys/server0
chmod 600 /etc/wireguard/keys/server0
wg genkey > /etc/wireguard/keys/server0
wg pubkey < /etc/wireguard/keys/server0 > /etc/wireguard/keys/server0.pub

touch /etc/wireguard/keys/client1
chmod 600 /etc/wireguard/keys/client1
wg genkey > /etc/wireguard/keys/client1
wg pubkey < /etc/wireguard/keys/client1 > /etc/wireguard/keys/client1.pub

touch /etc/wireguard/keys/client2
chmod 600 /etc/wireguard/keys/client2
wg genkey > /etc/wireguard/keys/client2
wg pubkey < /etc/wireguard/keys/client2 > /etc/wireguard/keys/client2.pub

touch /etc/wireguard/keys/client3
chmod 600 /etc/wireguard/keys/client3
wg genkey > /etc/wireguard/keys/client3
wg pubkey < /etc/wireguard/keys/client3 > /etc/wireguard/keys/client3.pub

touch /etc/wireguard/keys/client4
chmod 600 /etc/wireguard/keys/client4
wg genkey > /etc/wireguard/keys/client4
wg pubkey < /etc/wireguard/keys/client4 > /etc/wireguard/keys/client4.pub

touch /etc/wireguard/keys/client5
chmod 600 /etc/wireguard/keys/client5
wg genkey > /etc/wireguard/keys/client5
wg pubkey < /etc/wireguard/keys/client5 > /etc/wireguard/keys/client5.pub

touch /etc/wireguard/keys/client6
chmod 600 /etc/wireguard/keys/client6
wg genkey > /etc/wireguard/keys/client6
wg pubkey < /etc/wireguard/keys/client6 > /etc/wireguard/keys/client6.pub

touch /etc/wireguard/keys/client7
chmod 600 /etc/wireguard/keys/client7
wg genkey > /etc/wireguard/keys/client7
wg pubkey < /etc/wireguard/keys/client7 > /etc/wireguard/keys/client7.pub

touch /etc/wireguard/keys/client8
chmod 600 /etc/wireguard/keys/client8
wg genkey > /etc/wireguard/keys/client8
wg pubkey < /etc/wireguard/keys/client8 > /etc/wireguard/keys/client8.pub

touch /etc/wireguard/keys/client9
chmod 600 /etc/wireguard/keys/client9
wg genkey > /etc/wireguard/keys/client9
wg pubkey < /etc/wireguard/keys/client9 > /etc/wireguard/keys/client9.pub

touch /etc/wireguard/keys/client10
chmod 600 /etc/wireguard/keys/client10
wg genkey > /etc/wireguard/keys/client10
wg pubkey < /etc/wireguard/keys/client10 > /etc/wireguard/keys/client10.pub

touch /etc/wireguard/keys/client11
chmod 600 /etc/wireguard/keys/client11
wg genkey > /etc/wireguard/keys/client11
wg pubkey < /etc/wireguard/keys/client11 > /etc/wireguard/keys/client11.pub

####

echo "Step 07 - Setup wireguard server config"
echo
echo "[Interface]
Address = 10.8.0.1/24
Address = fd42:42:42:42::1/112
ListenPort = $wg0port
PrivateKey = SK01
# client1
[Peer]
PublicKey = PK01
AllowedIPs = 10.8.0.11/32, fd42:42:42:42::11/128
# client2
[Peer]
PublicKey = PK02
AllowedIPs = 10.8.0.12/32, fd42:42:42:42::12/128
# client3
[Peer]
PublicKey = PK03
AllowedIPs = 10.8.0.13/32, fd42:42:42:42::13/128
# client4
[Peer]
PublicKey = PK04
AllowedIPs = 10.8.0.14/32, fd42:42:42:42::14/128
# client5
[Peer]
PublicKey = PK05
AllowedIPs = 10.8.0.15/32, fd42:42:42:42::15/128
# client6
[Peer]
PublicKey = PK06
AllowedIPs = 10.8.0.16/32, fd42:42:42:42::16/128
# client7
[Peer]
PublicKey = PK07
AllowedIPs = 10.8.0.17/32, fd42:42:42:42::17/128
# client8
[Peer]
PublicKey = PK08
AllowedIPs = 10.8.0.18/32, fd42:42:42:42::18/128
# client9
[Peer]
PublicKey = PK09
AllowedIPs = 10.8.0.19/32, fd42:42:42:42::19/128
# client10
[Peer]
PublicKey = PK10
AllowedIPs = 10.8.0.20/32, fd42:42:42:42::20/128
# client11
[Peer]
PublicKey = PK11
AllowedIPs = 10.8.0.21/32, fd42:42:42:42::21/128
# -end of default clients
" > /etc/wireguard/wg0.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0)@" /etc/wireguard/wg0.conf
sed -i "s@PK01@$(cat /etc/wireguard/keys/client1.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK02@$(cat /etc/wireguard/keys/client2.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK03@$(cat /etc/wireguard/keys/client3.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK04@$(cat /etc/wireguard/keys/client4.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK05@$(cat /etc/wireguard/keys/client5.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK06@$(cat /etc/wireguard/keys/client6.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK07@$(cat /etc/wireguard/keys/client7.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK08@$(cat /etc/wireguard/keys/client8.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK09@$(cat /etc/wireguard/keys/client9.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK10@$(cat /etc/wireguard/keys/client10.pub)@" /etc/wireguard/wg0.conf
sed -i "s@PK11@$(cat /etc/wireguard/keys/client11.pub)@" /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf


####

echo "Step 08 - Setup wireguard client config"
echo
echo "[Interface]
Address = 10.8.0.11/32
Address = fd42:42:42:42::11/128
PrivateKey = CK01
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client1.conf
sed -i "s@CK01@$(cat /etc/wireguard/keys/client1)@" /etc/wireguard/client1.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client1.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client1.conf
chmod 600 /etc/wireguard/client1.conf

echo "[Interface]
Address = 10.8.0.12/32
Address = fd42:42:42:42::12/128
PrivateKey = CK02
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client2.conf
sed -i "s@CK02@$(cat /etc/wireguard/keys/client2)@" /etc/wireguard/client2.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client2.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client2.conf
chmod 600 /etc/wireguard/client2.conf

echo "[Interface]
Address = 10.8.0.13/32
Address = fd42:42:42:42::13/128
PrivateKey = CK03
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client3.conf
sed -i "s@CK03@$(cat /etc/wireguard/keys/client3)@" /etc/wireguard/client3.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client3.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client3.conf
chmod 600 /etc/wireguard/client3.conf

echo "[Interface]
Address = 10.8.0.14/32
Address = fd42:42:42:42::14/128
PrivateKey = CK04
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client4.conf
sed -i "s@CK04@$(cat /etc/wireguard/keys/client4)@" /etc/wireguard/client4.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client4.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client4.conf
chmod 600 /etc/wireguard/client4.conf

echo "[Interface]
Address = 10.8.0.15/32
Address = fd42:42:42:42::15/128
PrivateKey = CK05
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client5.conf
sed -i "s@CK05@$(cat /etc/wireguard/keys/client5)@" /etc/wireguard/client5.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client5.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client5.conf
chmod 600 /etc/wireguard/client5.conf

echo "[Interface]
Address = 10.8.0.16/32
Address = fd42:42:42:42::16/128
PrivateKey = CK06
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client6.conf
sed -i "s@CK06@$(cat /etc/wireguard/keys/client6)@" /etc/wireguard/client6.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client6.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client6.conf
chmod 600 /etc/wireguard/client6.conf

echo "[Interface]
Address = 10.8.0.17/32
Address = fd42:42:42:42::17/128
PrivateKey = CK07
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client7.conf
sed -i "s@CK07@$(cat /etc/wireguard/keys/client7)@" /etc/wireguard/client7.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client7.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client7.conf
chmod 600 /etc/wireguard/client7.conf

echo "[Interface]
Address = 10.8.0.18/32
Address = fd42:42:42:42::18/128
PrivateKey = CK08
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client8.conf
sed -i "s@CK08@$(cat /etc/wireguard/keys/client8)@" /etc/wireguard/client8.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client8.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client8.conf
chmod 600 /etc/wireguard/client8.conf

echo "[Interface]
Address = 10.8.0.19/32
Address = fd42:42:42:42::19/128
PrivateKey = CK09
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client9.conf
sed -i "s@CK09@$(cat /etc/wireguard/keys/client9)@" /etc/wireguard/client9.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client9.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client9.conf
chmod 600 /etc/wireguard/client9.conf

echo "[Interface]
Address = 10.8.0.20/32
Address = fd42:42:42:42::20/128
PrivateKey = CK10
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client10.conf
sed -i "s@CK10@$(cat /etc/wireguard/keys/client10)@" /etc/wireguard/client10.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client10.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client10.conf
chmod 600 /etc/wireguard/client10.conf

echo "[Interface]
Address = 10.8.0.21/32
Address = fd42:42:42:42::21/128
PrivateKey = CK11
DNS = 10.8.0.1, fd42:42:42:42::1
[Peer]
Endpoint = IP01:$wg0port
PublicKey = SK01
AllowedIPs = 0.0.0.0/0, ::/0
" > /etc/wireguard/client11.conf
sed -i "s@CK11@$(cat /etc/wireguard/keys/client11)@" /etc/wireguard/client11.conf
sed -i "s@SK01@$(cat /etc/wireguard/keys/server0.pub)@" /etc/wireguard/client11.conf
sed -i "s@IP01@$(hostname -I | awk '{print $1}')@" /etc/wireguard/client11.conf
chmod 600 /etc/wireguard/client11.conf



####

echo "Step 09 - Setup unbound"
echo
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


####

echo "Step 10 - Setup DNSCrypt"
echo
mkdir /etc/dnscrypt-proxy/
wget -O /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz https://github.com/jedisct1/dnscrypt-proxy/releases/download/2.0.42/dnscrypt-proxy-linux_x86_64-2.0.42.tar.gz
tar -xvzf /etc/dnscrypt-proxy/dnscrypt-proxy.tar.gz -C /etc/dnscrypt-proxy/
mv -f /etc/dnscrypt-proxy/linux-x86_64/* /etc/dnscrypt-proxy/
#
cp /etc/dnscrypt-proxy/example-blacklist.txt /etc/dnscrypt-proxy/blacklist.txt 
#
echo "listen_addresses = ['127.0.0.1:5353']
server_names = ['cloudflare-ipv6', 'cloudflare', 'dns.digitale-gesellschaft.ch', 'doh.ffmuc.net', 'ffmuc.net-v6', 'dns.digitale-gesellschaft.ch-ipv6']
#server_names = ['ffmuc.net-v6', 'doh.ffmuc.net', 'dns.digitale-gesellschaft.ch', 'doh-crypto-sx', 'dnscrypt.eu-dk', 'de.dnsmaschine.net', 'securedns-doh', 'securedns-ipv6-doh', 'dnscrypt.me-ipv6']
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
cache_max_ttl = 900
cache_neg_ttl = 60
[blacklist]
blacklist_file = 'blacklist.txt'
log_file = '/var/log/dnscrypt-proxy-blocked.log'
[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
  cache_file = 'public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''
[static]
" > /etc/dnscrypt-proxy/dnscrypt-proxy.toml

####

echo "Step 11 - Setup Blacklist and a Whitelist from (anudeepND)"
echo
mkdir /etc/dnscrypt-proxy/utils/
mkdir /etc/dnscrypt-proxy/utils/generate-domains-blacklists/
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/zzzkeil/Wireguard-DNScrypt-VPN-Server/master/blocklist/domains-blacklist-ultimate.conf
#curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist.conf https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-blacklist.conf
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-blacklist-local-additions.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-time-restricted.txt https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/domains-time-restricted.txt
#echo "" > /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-whitelist.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-whitelist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blacklists/generate-domains-blacklist.py

chmod +x /etc/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py
cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/
./generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt
cd
(crontab -l ; echo "00 21 * * * cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/ &&  ./generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt") | sort - | uniq - | crontab -
(crontab -l ; echo "00 10 * * * curl -o /etc/dnscrypt-proxy/utils/generate-domains-blacklists/domains-whitelist.txt https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt") | sort - | uniq - | crontab -
## check if generate blacklist failed - file is empty
echo "#!/bin/bash
if [[ -s /etc/dnscrypt-proxy/blacklist.txt ]]; then
exit 0
fi
cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/ &&  ./generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt
exit 0
" > /etc/dnscrypt-proxy/checkblacklist.sh
chmod +x /etc/dnscrypt-proxy/checkblacklist.sh
(crontab -l ; echo "15 * * * * cd /etc/dnscrypt-proxy/ &&  ./etc/dnscrypt-proxy/checkblacklist.sh") | sort - | uniq - | crontab -

####

echo "Step 90 - Setup systemctl"
echo
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
cp /etc/systemd/system/multi-user.target.wants/unbound.service /root/script_backupfiles/unbound.service.orig
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

/etc/dnscrypt-proxy/dnscrypt-proxy -service install
/etc/dnscrypt-proxy/dnscrypt-proxy -service start
systemctl restart unbound

####

echo "Step 91 - Set file for install check (see line 34)"
echo "Wireguard-DNScrypt-VPN-Server installed,
please remove all files/configs carefully,
before you delete this file and run the script again
" > /root/Wireguard-DNScrypt-VPN-Server.README

####

echo "Step 100 - finish :)"
echo ""
echo ""
echo "QR Code for client1.conf "
qrencode -t ansiutf8 < /etc/wireguard/client1.conf
echo "Scan the QR Code with your Wiregard App"
qrencode -o /etc/wireguard/client1.png < /etc/wireguard/client1.conf
qrencode -o /etc/wireguard/client2.png < /etc/wireguard/client2.conf
qrencode -o /etc/wireguard/client3.png < /etc/wireguard/client3.conf
qrencode -o /etc/wireguard/client4.png < /etc/wireguard/client4.conf
qrencode -o /etc/wireguard/client5.png < /etc/wireguard/client5.conf
qrencode -o /etc/wireguard/client6.png < /etc/wireguard/client6.conf
qrencode -o /etc/wireguard/client7.png < /etc/wireguard/client7.conf
qrencode -o /etc/wireguard/client8.png < /etc/wireguard/client8.conf
qrencode -o /etc/wireguard/client9.png < /etc/wireguard/client9.conf
qrencode -o /etc/wireguard/client10.png < /etc/wireguard/client10.conf
qrencode -o /etc/wireguard/client11.png < /etc/wireguard/client11.conf
echo "10 extra client.conf and QR Codes files in folder : /etc/wireguard/"
echo ""
echo
echo
ln -s /etc/wireguard/ /root/wireguard_folder
ln -s /etc/dnscrypt-proxy/ /root/dnscrypt-proxy_folder
ln -s /var/log /root/system-log_folder
ufw --force enable
ufw reload
