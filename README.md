# linux-troubleshooting-project

A small lab for practising Linux troubleshooting. I run an Ubuntu VM with nginx on it, break something on purpose, then work out what went wrong and fix it like I would on a real server.

## What's in here
- `break.sh` breaks the server in one of six ways: disk, cpu, permissions, port, config or logs. `random` picks one without telling you which.
- `triage.sh` is the first thing I run when something's wrong. It checks disk space, CPU load, the busiest processes, whether nginx is up, whether anything is on port 80, whether the website responds, and the last few requests in the nginx log.
- `runbooks/` has a write-up for each problem I've solved: what I saw, what I checked, how I fixed it and how to stop it happening again.
- `screenshots/` has the terminal output that goes with each runbook.

## Setup
I used Multipass on a Mac:

```
multipass launch --name lab
multipass mount . lab:/home/ubuntu/lab
multipass shell lab
sudo apt update && sudo apt install -y nginx
```

## Running it
```
cd ~/lab
sudo bash break.sh cpu
bash triage.sh
```

## Done so far
- Disk full from a deleted file that was still open
- CPU hog disguised as a backup service
- Bot attack and 502s in the nginx log
