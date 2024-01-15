#!/bin/bash


OCIFNAME="vpns0"
OCwhitelist_domains='"example1.com" "example2.com"'


apt update
apt install -y git gcc libevent-dev tor
git clone https://github.com/darkk/redsocks.git
cd redsocks
make
cp redsocks /sbin/

cat>/etc/tor/torrc<<EOF
# Seting up TOR transparent proxy for tor-router
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
EOF

if [ $? -eq 0 ]
then
	echo "write tor config success"
else
	echo "write tor config fail"
fi

cat>/etc/redsocks.conf<<EOF
base {
        log_debug = off;
        log_info = on;
        log = stderr;
        daemon = off;
        redirector = iptables;
}
redsocks {
    local_ip = 0.0.0.0;   // 使用0.0.0.0即可允许其他主机流量进入，使用127.0.0.1只能本机流量进入,如果127vpn流量进不来，具体要看redirect怎么操作的，不知道是看源地址还是目的地址
    local_port = 50080;   // Redsocks监听端口

    ip = 127.0.0.1;
    port = 9050;    // 填写Tor监听端口

    type = socks5;
    // 可选 自定义登录用户名和密码
    // login = "username";
    // password = "password";
}
EOF
if [ $? -eq 0 ]
then
        echo "create redsocks config success"
else
        echo "error:create redsocks config fail"
fi

cat>/usr/lib/systemd/system/redsocks.service<<EOF
[Unit]
Description=Redsocks Service

[Service]
Type=simple
ExecStart=/usr/sbin/redsocks -c /etc/redsocks.conf
Restart=on-failure
RestartSec=1

[Install]
WantedBy = multi-user.target
EOF

if [ $? -ne 0 ]; then
    echo "error:create redsocks service failed"
else
    echo "create redsocks service succeed"
fi

cat>/usr/lib/systemd/system/tor4oc.service<<EOF
[Unit]
Description=tor4oc Service

[Service]
Type=simple
ExecStart=/usr/bin/tor4oc start
ExecStop=/usr/bin/tor4oc stop
RemainAfterExit=yes
 TimeoutStopSec=180
 KillMode=process
 KillSignal=SIGINT

[Install]
WantedBy = multi-user.target
EOF

if [ $? -ne 0 ]; then
    echo "error:create tor4oc  service failed"
else
    echo "create redsocks tor4oc  succeed"
fi

cat>/usr/bin/tor4oc<<EOF
#!/bin/bash

whitelist_domains=($OCwhitelist_domains)
IFNAME=$OCIFNAME
function start()
{
    # 创建新链REDSOCKS
    # iptables -t nat -F PREROUTING
    #iptables -t nat -F REDSOCKS
    #iptables -t nat -X REDSOCKS

    iptables -t nat -N REDSOCKS -m comment --comment "Add new chain for redsocks"

    # 本地网络地址放行不进行转发
    #iptables -t nat -A REDSOCKS -p udp --dport 53 -j REDIRECT --to-ports 5353
    iptables -t nat -I REDSOCKS -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:5353 -m comment --comment "Proxy 53 port DNS"
    iptables -t nat -A REDSOCKS -p icmp -j RETURN -m comment --comment "Enable ping"
    iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN -m comment --comment "Skip for Intranet"
    iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN -m comment --comment "Skip for Intranet"

    # 将REDSOCKS链上的流量全部转发至Redsocks监听的端口
    iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 50080 -m comment --comment "Redirect traffic to tor"

    # 将Tor流量不进行转发（若全部流量都进行转发则Tor将无法正常运行）
    # 使用UID进行流量的过滤，查看Tor进程的启动用户： ps -ef | grep tor
    # iptables -t nat -A OUTPUT -p tcp -m owner \\! --uid-owner \$(id -u debian-tor) -j REDSOCKS
    # iptables -t nat -A OUTPUT -p tcp -j REDSOCKS -m comment --comment "From OUTPUT jump to REDSOCKS"

    # 路由前的数据包也全部跳转到REDSOCKS链
    iptables -t nat -A PREROUTING -i \$IFNAME -j REDSOCKS -m comment --comment "From PREROUTING jump to REDSOCKS"

    # 加入转发
    iptables -t nat -A POSTROUTING -j MASQUERADE -m comment --comment "Masquerade by REDSOCKS"

    # 屏蔽未匹配数据
    iptables -t nat -A REDSOCKS -j MARK --set-mark 0x1000 -m comment --comment "Mark label for reject pkg"
    iptables -I FORWARD -m mark --mark 0x1000 -j REJECT -m comment --comment "Reject forward by REDSOCKS"

    # 设置域名白名单
    for e in \${whitelist_domains[@]}
    do
        iptables -t nat -I REDSOCKS -j RETURN -d \$e -m comment --comment 'Whitelist domain: '"\$e"
    done
}

function stop()
{
    iptables -t nat -D PREROUTING -i \$IFNAME -j REDSOCKS -m comment --comment "From PREROUTING jump to REDSOCKS"
    iptables -t nat -F REDSOCKS
    iptables -t nat -X REDSOCKS
    iptables -t nat -D POSTROUTING -j MASQUERADE -m comment --comment "Masquerade by REDSOCKS"
    iptables -D FORWARD -m mark --mark 0x1000 -j REJECT -m comment --comment "Reject forward by REDSOCKS"
}

if [ \$1 = "start" ]
then
        start
elif [ \$1 = "stop" ]
then
        stop
else
        echo "start or stop"
fi
EOF
if [ $? -ne 0 ]; then
    echo "error:create tor4oc cmd  failed"
else
    echo "create redsocks tor4oc  cmd succeed"
fi


chmod +x /usr/bin/tor4oc


systemctl restart tor
systemctl enable tor
systemctl restart redsocks
systemctl enable redsocks
systemctl restart tor4oc
systemctl enable tor4oc
iptables -t nat -nvL --line-numbers

# 火星包支持，否则无法代理dns
echo "net.ipv4.conf.$OCIFNAME.route_localnet=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.$OCIFNAME.route_localnet=1" >> /etc/sysctl.d/99-sysctl.conf
sysctl -p

# 删除redsocks/文件夹
cd ..
rm -rf redsocks/

echo "done"
