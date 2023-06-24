#!/bin/bash
if [[ -s /etc/dnscrypt-proxy/blocklist.txt ]]; then
exit 0
fi
cd /etc/dnscrypt-proxy/utils/generate-domains-blocklists/ &&  ./generate-domains-blocklist.py > /etc/dnscrypt-proxy/blocklist.txt
exit 0
