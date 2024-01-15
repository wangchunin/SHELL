#!/bin/bash
output=$(ip netns exec ns1 nslookup -type=a 4.ipw.cn 223.5.5.5)
arr=($output)
ip=${arr[-1]}
sed -i '/4.ipw.cn/d' /etc/hosts
echo "$ip 4.ipw.cn" >> /etc/hosts
ipv4=$(ip netns exec ns1 curl 4.ipw.cn 2>/dev/null)
echo $ipv4
