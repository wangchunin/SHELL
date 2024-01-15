#!/bin/bash

if [[ $2 == https://* ]];then
	echo "Don't use with prefix, use domain"
	exit -1
elif [[ $2 == http://* ]];then
	echo "Don't use with prefix, use domain"
	exit -1
fi
if [ $# -eq 3 ]; then
	echo "Use specified IP: $3"
	if [[ $2 =~ ":" ]]
	then
	echo "非标准端口的自定义解析IP（自定义CDN IP） 暂不支持重定向到其他端口，如http(8080)到https(8443)这种，可以根据返回的Url值，重写命令"
	RES=$(curl -L -o /dev/null -s -w "%{time_namelookup} %{time_connect} %{time_starttransfer} %{time_total} %{speed_download} %{url_effective} %{size_download} %{time_redirect}\n" "$1://$2" --resolve $2:$3)
	else
	RES=$(curl -L -o /dev/null -s -w "%{time_namelookup} %{time_connect} %{time_starttransfer} %{time_total} %{speed_download} %{url_effective} %{size_download} %{time_redirect}\n" "$1://$2" --resolve $2:80:$3 --resolve $2:443:$3)
	fi
elif [ $# -eq 2 ]; then
	echo "Use auto DNS resolve IP"
	RES=$(curl -L -o /dev/null -s -w "%{time_namelookup} %{time_connect} %{time_starttransfer} %{time_total} %{speed_download} %{url_effective} %{size_download} %{time_redirect}\n" "$1://$2")
else
	echo "Argument error"
	echo "./hping.sh http|https rn.melulu.top(:443) 104.19.19.19"
	echo "./hping.sh http|https rn.melulu.top"
	echo "两个参数时，http默认80，https默认443；三个参数时，可以支持自定义端口，但是对重定向支持不好，因为自定义解析IP时，需要提供确切的端口号"
	exit -1
fi

ARR=($RES)
#echo ${ARR[@]}
echo "Url redirect: ${ARR[5]}"
DNS=$(echo "scale=3;${ARR[0]}*1000/1"|bc)
Connect=$(echo "scale=3;${ARR[1]}*1000/1"|bc)
Redirect=$(echo "scale=3;${ARR[7]}*1000/1"|bc)
Transfer=$(echo "scale=3;${ARR[2]}*1000/1"|bc)
Total=$(echo "scale=3;${ARR[3]}*1000/1"|bc)
Speed=$(echo "scale=3;${ARR[4]}/1024"|bc)
Size=$(echo "scale=3;${ARR[6]}/1024"|bc)
echo  "顺序（时间都是从最开始算）：time_namelookup->time_connect->time_appconnect->time_pretransfer->time_redirect->time_starttransfer->time_total"
echo  "DNS:		$(printf "%.2f" ${DNS})		ms"
echo  "Connect: 	$(printf "%.2f" ${Connect})		ms	从开始到TCP建立成功时间，包括DNS的时间"
echo  "Redirect: 	$(printf "%.2f" ${Redirect})		ms	仅仅包含重定向时间，如果没有重定向，此值为0"
echo  "Transfer: 	$(printf "%.2f" ${Transfer})		ms	从开始到第一个字节传回来时间，包括前面的所有时间，还包括SSL建立、协议商量等步骤，这里没有展示，包括重定向"
echo  "Total:		$(printf "%.2f" ${Total})		ms	总时间，包括前面所有"
echo  "Speed:		$(printf "%.2f" ${Speed})		KB/s	应该是从Total总时间计算的"
echo  "Size:		$(printf "%.2f" ${Size})		KB"

# 有用文献
# https://cloud.tencent.com/developer/article/1512011
# https://blog.csdn.net/m0_37549390/article/details/86552116
# https://blog.csdn.net/ximaiyao1984/article/details/126886645
