#!/bin/bash
OCIFNAME="vpns0"
bash <(curl -fsSL git.io/warp.sh) 4
if [ $? -eq 0 ]
then
sed -i "/cmd\ ip\ \$proto\ rule\ add\ table\ main\ suppress_prefixlength\ 0/a\cmd\ ip\ \$proto\ rule\ add\ from\ all\ iif\ ${OCIFNAME}\ table\ \$table\ prio\ 20" /usr/bin/wg-quick
sed -i "s/^[^#].*cmd\ ip\ \$proto\ rule\ add\ not\ fwmark\ \$table\ table\ \$table$/#&/g" /usr/bin/wg-quick
else
	echo "If VPS only support IPv4, you need del the ipv6 setting in /etc/warp/{profile}, and reuse this script, dont del the warp config, script will use it agin, or script will regisiter,maybe baned by cloudflare for regisiting many times in WARP"
	echo "Now exit!"
fi
