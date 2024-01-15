#!/bin/bash
cd /root/cf &&  ip netns exec ns1 ./CloudflareST  -n 100 -t 10 -tll 15  -url https://rn.melulu.top/__200MB.test
#cd /root/cf &&  ip netns exec ns1 ./CloudflareST_wcl -n 2   -sl 10 -url https://rn.melulu.top/__200MB.test -f subip.txt
