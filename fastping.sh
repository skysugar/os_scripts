#!/bin/bash


toping(){
  ping -c 1 -w 1 -q $1 > /dev/null
  [ $? -eq 0 ] && echo $1 is online...
}

ip=${1%.*}
t=${2}

[ $# -ne 2 ] && echo args err ! && exit 1

for i in $(seq 1 $2 254)
do
  n=$i
  while [ $n -lt $((i+t)) ]
  do
      toping $ip.$n &
      n=$((n+1))
      [ $n -ge 255 ] && break
  done
  wait
done
