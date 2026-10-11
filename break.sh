#!/bin/bash
# break-level2.sh: harder problems that hide their cause
# Usage: bash break-level2.sh <disk|cpu|permissions|port|config|logs|random>

CONFIG=/etc/nginx/sites-enabled/default

disk() {
  # Fill the disk, then delete the file while a process still has it open
  fallocate -l 10G /var/log/cache.tmp
  nohup sleep infinity < /var/log/cache.tmp > /dev/null 2>&1 &
  rm /var/log/cache.tmp
}

cpu() {
  # A CPU hog disguised as a backup service that restarts itself
  cat > /usr/local/bin/backup-agent << 'EOF'
#!/bin/bash
while true; do :; done
EOF
  chmod +x /usr/local/bin/backup-agent
  cat > /etc/systemd/system/backup-agent.service << 'EOF'
[Unit]
Description=Backup agent

[Service]
ExecStart=/usr/local/bin/backup-agent
Restart=always

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl start backup-agent
}

permissions() {
  # Lock the folder, not the file
  chmod 700 /var/www/html
}

port() {
  # Another program takes port 80 while nginx is stopped
  systemctl stop nginx
  mkdir -p /tmp/imposter
  echo "Wrong server" > /tmp/imposter/index.html
  nohup python3 -m http.server 80 --directory /tmp/imposter > /dev/null 2>&1 &
  sleep 1
  systemctl start nginx 2> /dev/null
}

config() {
  # Valid config, but pointing at a folder that doesn't exist
  sed -i 's|root /var/www/html;|root /var/www/htm;|' $CONFIG
  systemctl reload nginx
}

logs() {
  # Add suspicious traffic and an outage to the nginx log
  for i in $(seq 1 200); do
    echo "203.0.113.45 - - [$(date '+%d/%b/%Y:%H:%M:%S %z')] \"POST /wp-login.php HTTP/1.1\" 404 162 \"-\" \"python-requests/2.31\"" >> /var/log/nginx/access.log
  done
  for i in $(seq 1 20); do
    echo "198.51.100.$i - - [$(date '+%d/%b/%Y:%H:%M:%S %z')] \"GET /api/orders HTTP/1.1\" 502 0 \"-\" \"Mozilla/5.0\"" >> /var/log/nginx/access.log
  done
}

case "$1" in
  disk|cpu|permissions|port|config|logs)
    $1
    echo "Broke: $1. Now find and fix it."
    ;;
  random)
    pick=$(echo "disk cpu permissions port config logs" | tr ' ' '\n' | shuf -n 1)
    $pick
    echo "$pick" > /root/.last-break
    echo "Something is broken. Find out what."
    ;;
  *)
    echo "Usage: bash break-level2.sh <disk|cpu|permissions|port|config|logs|random>"
    exit 1
    ;;
esac