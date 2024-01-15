#!/bin/sh
tries=0
while [[ $tries -lt 5 ]]
do
        if /bin/ping -c 1 8.8.8.8  >/dev/null
        then
            logger "network pass, exit."
            exit 0
        fi
        tries=$((tries+1))
        sleep 5
done
            logger "network error, restart."
/etc/init.d/network restart
echo $(date +%Y-%m-%d\ %H:%M:%S) >> /root/netwatch.txt
echo -e ": 重启网络成功\n" >> /root/netwatch.txt 
