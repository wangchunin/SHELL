docker run --restart unless-stopped -d --name oc  --network macnet --privileged chunlinwang/ocserver:latest /sbin/init
docker network create -d macvlan --subnet=192.168.8.0/24 --gateway=192.168.8.1 -o parent=eth0 macnet
docker push chunlinwang/ocserver
docker commit -m "20220725" -a "wangchunlin" oc  chunlinwang/ocserver:latest

v2ray服务器	201在用
passwall    	202在用
