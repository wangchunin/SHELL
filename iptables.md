### iptables 基本参数解释
-P	设置默认策略<br>
-F	清空规则链<br>
-D	删除某个规则<br>
-L	查看规则链<br>
-n	输出全部显示为数字<br>
-A	在规则链末尾添加规则，优先级最低<br>
-I	在规则链头部添加规则，优先级高<br>
-s	匹配来源地址<br>
! -s	上条规则取反<br>
-d	匹配目标地址<br>
-i	匹配从这块网卡流入的数据<br>
-o	匹配从这块网卡流出的数据<br>
-p	匹配协议TCP、UDP、ICMP<br>
--dport	匹配目标端口号<br>
--sport	匹配来源端口号<br>
```
示例：
iptables -P INPUT DROP #更改默认INPUT策略为DROP，即丢弃所有入网连接
iptables -t nat -nL #查看nat表中的所有规则
iptables -t nat -F #清空nat表中的所有规则
iptables -I INPUT -s 1.1.1.1 -j ACCEPT #允许1.1.1.1连接本机
iptables -D INPUT -s 1.1.1.1 -j ACCEPT #清除上一条规则
iptables -I INPUT ! -s 1.1.1.1 -j ACCEPT #不允许1.1.1.1连接本机
iptables -I OUTPUT -s  1.1.1.1 --dport 80 -j DROP #拒绝本机连接1.1.1.1:80
iptables -I OUTPUT -s  1.1.1.1 --sport 80 -j DROP #拒绝1.1.1.1:80连接本机
```
#限速命令
```
#80 443端口限速512k，每个访问的IP都限制
iptables -A INPUT -i ens3 -p tcp -m multiport --dport 80,443 -m hashlimit --hashlimit-above 512kb/s --hashlimit-mode srcip --hashlimit-name in -j DROP			

#将监听在127.0.0.1:1000的服务暴露至某个IP上，需要更改内核参数 net.ipv4.conf.ens3.route_localnet=1
iptables -t nat -A PREROUTING -p tcp --dport 1000 -j DNAT --to-destination 127.0.0.1:1000
```

