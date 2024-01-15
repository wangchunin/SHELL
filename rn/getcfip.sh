#!/bin/bash
awk -F, 'NR==2{print $1}' /root/cf/result.csv


