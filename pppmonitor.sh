#!/bin/bash
#pptpd client monitor script.

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8

#----change rip and pname
rip=103.24.95.5
pname=pptpd
#------------------------

pppcon() {
  pppd call $1 
  sleep 3
  route add -net 0.0.0.0 dev ppp0
  echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" >/etc/resolv.conf
}

checkstatus(){
  pppstats > /dev/null 2>&1
  if [ $? -eq 0 ] ; then
    curl -s ifconfig.me | grep -w $1 > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
      return 0
    else
      return 2
    fi
  else
    return 1
  fi
}

checkstatus $rip
case $? in
0)
  echo pppd connections...
;;
1)
  pppcon $pname
;;
2)
  killall pppd pptp
  pppcon $pname
;;
*)
  echo unknown error.
;;
esac
