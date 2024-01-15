#!/bin/bash

RES=$(curl -o /dev/null  -s -w "%{time_namelookup} %{time_connect} %{time_starttransfer} %{time_total} %{speed_download}\n" "http://$1")
ARR=($RES)
DNS=$(echo "scale=3;${ARR[0]}*1000/1"|bc)
Connect=$(echo "scale=3;${ARR[1]}*1000/1"|bc)
Transfer=$(echo "scale=3;${ARR[2]}*1000/1"|bc)
Total=$(echo "scale=3;${ARR[3]}*1000/1"|bc)
Speed=$(echo "scale=3;${ARR[4]}/1000"|bc)
echo  "DNS:		$(printf "%.2f" ${DNS})		ms"
echo  "Connect: 	$(printf "%.2f" ${Connect})		ms"
echo  "Transfer: 	$(printf "%.2f" ${Transfer})		ms"
echo  "Total:		$(printf "%.2f" ${Total})		ms"
echo  "Speed:		$(printf "%.2f" ${Speed})		KB/s"

# 有用文献
# https://cloud.tencent.com/developer/article/1512011
# https://blog.csdn.net/m0_37549390/article/details/86552116
# https://blog.csdn.net/ximaiyao1984/article/details/126886645
