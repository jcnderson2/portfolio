#!/bin/bash

# What this does:
# It outputs basic statistic information from the system its ran on to '/var/logs/health-check-DATEANDTIME.log'

# Why this was made:
# Uploading this to our tenants' screenconnect toolbox simply allows us to get this information quicker when troubleshooting linux machines which are not always servers.

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOGFILE="/var/log/health-check-$TIMESTAMP.log"

echo "=== System Health Check at $TIMESTAMP ===" | tee -a "$LOGFILE"

# Uptime
echo -e "\n[+] Uptime:" | tee -a "$LOGFILE"
uptime | tee -a "$LOGFILE"

# Load Average (The primary goal)
echo -e "\n[+] Load Average (1, 5, 15 min):" | tee -a "$LOGFILE"
cat /proc/loadavg | awk '{print $1, $2, $3}' | tee -a "$LOGFILE"

# CPU Usage
echo -e "\n[+] CPU Usage:" | tee -a "$LOGFILE"
top -bn1 | grep "Cpu(s)" | awk '{print "Used: " $2+$4 "%"}' | tee -a "$LOGFILE"

# Memory Usage
echo -e "\n[+] Memory Usage:" | tee -a "$LOGFILE"
free -h | tee -a "$LOGFILE"

# Disk Usage
echo -e "\n[+] Disk Usage (Root /):" | tee -a "$LOGFILE"
df -h / | tee -a "$LOGFILE"

# Top 5 processes by memory
echo -e "\n[+] Top 5 Processes by Memory:" | tee -a "$LOGFILE"
ps -eo pid,comm,%mem,%cpu,args --sort=-%mem | cut -c -120 | head -n 6 | tee -a "$LOGFILE"

# Top 5 processes by CPU
echo -e "\n[+] Top 5 Processes by CPU:" | tee -a "$LOGFILE"
ps -eo pid,comm,%mem,%cpu,args --sort=-%cpu | cut -c -120 | awk 'NR<=6' | tee -a "$LOGFILE"

# Failed services
echo -e "\n[+] Failed Services:" | tee -a "$LOGFILE"
systemctl --failed | tee -a "$LOGFILE"

echo -e "\n[✓] Health check completed\n" | tee -a "$LOGFILE"
