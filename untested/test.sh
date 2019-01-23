#!/bin/bash


apt install iptables-persistent -y 

clear

#Step 03 - Setup iptabels
clear
inet=$(ip route show default | awk '/default/ {print $5}')
#ipv4
iptables -P INPUT DROP
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport $sshport -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport $wg0port -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $inet -j MASQUERADE
iptables -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v4


#ipv6
ip6tables -P INPUT DROP
ip6tables -A INPUT -i lo -p all -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport $sshport -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp -m udp --dport $wg0port -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ip6tables -A INPUT -s fd42:42:42:42::/112 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -s fd42:42:42:42::/112 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -t nat -A POSTROUTING -s fd42:42:42:42::/112 -o $inet -j MASQUERADE
ip6tables -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v6

systemctl enable netfilter-persistent
netfilter-persistent save
