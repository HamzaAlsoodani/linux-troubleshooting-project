#!/bin/bash

echo "Disk space"
df -h /

echo ""
echo "CPU load"
uptime

echo ""
echo "Busiest processes"
ps aux --sort=-%cpu | head -4

echo ""
echo "Is nginx running?"
systemctl is-active nginx

echo ""
echo "Is anything listening on port 80?"
ss -tln | grep ":80 " || echo "Nothing is listening on port 80"

echo ""
echo "Does the website work?"
curl -I -s http://localhost | head -1

echo ""
echo "Last 5 requests in the nginx log"
tail -n 5 /var/log/nginx/access.log