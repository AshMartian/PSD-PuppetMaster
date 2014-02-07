#!/bin/sh
clear
echo 'Sending computer information to Tech Support......     '

mac=`ifconfig | grep HWaddr | head -n1 | base64`;
name=`cat /etc/hostname | base64`;
sysserial=`dmidecode -s system-serial-number`;
osid=`echo 50 | base64`;
imageid=`echo 2 | base64`;
ip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}' | base64`

data="mac=${mac}&host=${name}&serial=${sysserial}&advanced=1&osid=${osid}&imageid=${imageid}";

res="";

res=`wget -O - --post-data="${data}" "http://fog.psd401.net/fog/service/auto.register.php" 2>/dev/null`
echo "${res}"


exit 0
