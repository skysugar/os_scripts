#!/bin/bash
/sbin/iptables -F
/sbin/iptables -F -t nat
/sbin/iptables -X
/sbin/iptables -P INPUT DROP
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT

#load connection-tracking modules

#any



#ENABLE FOR FORWARDING SERVERS
/sbin/iptables -A INPUT -f -m limit --limit 100/sec --limit-burst 100 -j DROP
/sbin/iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 10 -j DROP
/sbin/iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -m limit --limit 20/sec --limit-burst 200 -j DROP
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -m state --state INVALID,NEW -j DROP
