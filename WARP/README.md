## 安装 WireGuard
```
echo "deb http://deb.debian.org/debian buster-backports main" >>/etc/apt/sources.list
apt -y update 
apt -y upgrade
#手动重启
apt -t buster-backports install wireguard wireguard-tools wireguard-dkms linux-headers-$(uname -r)
modprobe wireguard
```
## 注册 WARP
```
wget https://github.com/ViRb3/wgcf/releases/download/v2.2.3/wgcf_2.2.3_linux_amd64
chmod +x wgcf_2.2.3_linux_amd64
./wgcf_2.2.3_linux_amd64 register
./wgcf_2.2.3_linux_amd64 generate
mv wgcf-profile.conf /etc/wireguard/wgcf.conf


#保活
echo "PersistentKeepalive = 10" >>/etc/wireguard/wgcf.conf
#注释多余行
sed -i '/Address/#Address/g' /etc/wireguard/wgcf.conf
sed -i '/DNS/#DNS/g' /etc/wireguard/wgcf.conf
sed -i '/MTU/#MTU/g' /etc/wireguard/wgcf.conf
```
## 路由配置
```
#WARP地址走100路由表
ip rule add to 162.159.192.1 table 100
#访问本机IP的走100路由表，192.168.0.2是本机IP，192.168.0.1是网关IP，eth0是网卡名称
ip rule add from 192.168.0.2 table 100
ip route add default via 192.168.0.1 dev eth0 table 100

#指定WGCF的IP通过物理网卡访问
ip route add 162.159.192.1 via 45.130.146.1 dev ens18

ip link add wgcf type wireguard
wg setconf wgcf /etc/wireguard/wgcf.conf
ip -4 address add 172.16.0.2/32 dev wgcf
#ip -6 address add fd01:5ca1:ab1e:82f1:bfa8:d22b:435b:f4a3/128 dev wgcf  #添加IPV6时需要
ip link set mtu 1280 up dev wgcf

#将默认路由改为wgcf
ip route change default dev wgcf 
#添加IPV6默认路由
#ip -6 route add default dev wgcf
```


