server:
num-threads: 1
verbosity: 1
root-hints: "/var/lib/unbound/root.hints"
interface: 0.0.0.0
interface: ::0
max-udp-size: 3072
access-control: 0.0.0.0/0                 refuse
access-control: 127.0.0.0/24                 allow
access-control: 10.networkv4.0/24         allow
access-control: ::1                   allow
access-control: fd42:networkv6::1/64         allow
private-address: 10.networkv4.0/24 
private-address: fd42:networkv6::1/64
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
