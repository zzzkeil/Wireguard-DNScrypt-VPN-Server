#!/bin/bash
clear
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

# Here i´m working now ----  Not finished !!  caution learning by doing !!
#Step 03 - Setup iptabels
#ipv4
iptables -P INPUT DROP
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
iptables -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v4
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/iptables/rules.v4

#ipv6
ip6tables -P INPUT DROP
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
ip6tables -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v6
sed -i "s/eth0/$(route | grep '^default' | grep -o '[^ ]*$')/" /etc/iptables/rules.v6
systemctl restart sshd.service
systemctl enable netfilter-persistent
netfilter-persistent save
