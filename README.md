### Linux 网络重装系统脚本
理论支持 CentOS6及以下，Debian 和Ubuntu，可能会造成失联，机器不能通过面板重置系统的或没有VNC的不建议使用<br>
```
curl -k https://raw.githubusercontent.com/GouGoGoal/SHELL/master/InstallNET.sh|bash -d 10 -v 64 -a [-p PassWord] [-i eth0] [--mirror  ...]
```
-d 10 为Debian 10<br>
-v 为64位系统<br>
-a 自动运行，无需在VNC里手动操作(理想情况下)<br>
-p 指定密码，若不指定默认为 MoeClub.org<br>
-i 指定网卡，多网卡的时候需要指定，单网卡可以忽略<br>
--mirror 指定源，同地区的源装系统会更快，默认是美国源，下方为Debian源<br>
```
大陆源
--mirror 'http://mirrors.ustc.edu.cn/debian/'
香港源
--mirror 'http://ftp.hk.debian.org/debian/'
台湾源
--mirror 'http://ftp.tw.debian.org/debian/'
日本源
--mirror 'http://ftp.jp.debian.org/debian/'
韩国
--mirror 'http://ftp.kr.debian.org/debian/'
新加坡
--mirror 'http://mirror.0x.sg/debian/'
俄罗斯
--mirror 'http://ftp.ru.debian.org/debian/'
```
### [forward.sh](https://raw.githubusercontent.com/GouGoGoal/SHELL/master/forward.sh) iptables端口转发工具
使用iptables进行转发，性能最快，但不支持负载均衡，下载完成后编辑查看如何使用<br>
### 一键添加swap
```
curl -k https://raw.githubusercontent.com/GouGoGoal/SHELL/master/addswap.sh|bash [1024]
```
某些模板开机的Linux系统没有swap，添加swap以提高系统稳定性<br>
参数以M为单位添加，若没有参数则添加和当前RAM一样大小的swap<br>
### [BestTrace](https://raw.githubusercontent.com/GouGoGoal/SHELL/master/besttrace) 路由追踪工具
下载到Linux上，给执行权限，就可以了，besttrace [-g cn] 1.1.1.1<br>
### [TCPing](https://raw.githubusercontent.com/GouGoGoal/SHELL/master/tcping) 查看TCP延迟
下载到Linux上，给执行权限，就可以了，tcping 1.1.1.1<br>
### [Nginx](https://github.com/GouGoGoal/SHELL/tree/master/Nginx) 的使用方法技巧




