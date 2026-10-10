#!/bin/bash
# break.sh: breaks the server on purpose so I can practise fixing it
# Usage: bash break.sh cpu

if [ "$1" = "cpu" ]; then
  # Start 4 programs that use 100% CPU
  for i in 1 2 3 4; do yes > /dev/null & done

elif [ "$1" = "disk" ]; then
  # Create a 10G file to fill the disk
  fallocate -l 10G /var/log/huge-app.log

elif [ "$1" = "permissions" ]; then
  # Take away all permissions from the web page
  chmod 000 /var/www/html/index.nginx-debian.html

elif [ "$1" = "errors" ]; then
  # Visit a page that doesn't exist 30 times
  for i in $(seq 1 30); do curl -s http://localhost/missing-page > /dev/null; done

elif [ "$1" = "port" ]; then
  # Move nginx from port 80 to port 8081
  sed -i 's/80 default_server/8081 default_server/' /etc/nginx/sites-enabled/default
  systemctl restart nginx

elif [ "$1" = "config" ]; then
  # Delete a semicolon from the nginx config so it's invalid
  sed -i 's/listen 80 default_server;/listen 80 default_server/' /etc/nginx/sites-enabled/default
  systemctl restart nginx

else
  echo "Usage: bash break.sh <cpu|disk|permissions|errors|port|config>"
  exit 1
fi
