#!/bin/bash
if [[ -s /etc/dnscrypt-proxy/blacklist.txt ]]; then
exit 0
fi
cd /etc/dnscrypt-proxy/utils/generate-domains-blacklists/ &&  ./generate-domains-blacklist.py > /etc/dnscrypt-proxy/blacklist.txt
exit 0
