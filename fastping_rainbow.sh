#!/bin/bash

# check the parameter
if [ $# -lt 1 ]; then
  echo "Examples:"
  echo ${0} 10.60.1
  echo ${0} 10.99.1
  exit 1
fi

# C type subnet
subnet=$1
# retry times
retry=1
# timeout seconds
timeout=1

# clean the output file
> /tmp/ping.output

# close the background return
exec 3>&2
exec 2>/dev/null

# ping as paraller mode and write output into file
for i in {0..255}
do 
  # timeout: 1 second, retry: 1 time
  ping -c ${retry} -w ${timeout} -q ${subnet}.${i} &> /dev/null && echo ${i} >> /tmp/ping.output & disown $! 
done

# restore the backgroud return
exec 2>&3
exec 3>&-

# wait for 1 more second to get correct result
#sleep $((${timeout}+1))
wait

# print output with better order
sum=$(wc -l /tmp/ping.output |awk '{print $1}')
echo "There are ${sum} online ipaddress in subnetwork ${subnet}.0/24:"
cat /tmp/ping.output | sort -t"." -k1,1n -k2,2n -k3,3n -k4,4n | xargs
