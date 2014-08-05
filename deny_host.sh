#!/bin/bash
#DenyHosts Shell Script
#2011-04-11
list="127.0.0.1"
cat /var/log/secure | awk '/Failed/ {print $(NF -3)}' | sort |uniq -c |awk '{print $2"="$1;}' > /tmp/black.txt
DEFINE="20"
for i in `cat /tmp/black.txt`
do
        IP=`echo $i |awk -F = '{print $1}'`
        echo $list | grep -w $IP > /dev/null && continue
        NUM=`echo $i | awk -F = '{print $2}'`
        if [ $NUM -gt $DEFINE ]; then
                grep $IP /etc/hosts.deny > /dev/null
                if [ $? -gt 0 ]; then
                        echo "all:$IP" >> /etc/hosts.deny
                fi
        fi
done
