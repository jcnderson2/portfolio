#!/bin/bash

# What this does:
# Analyzes '/var/log/auth.log' for suspicious login activity and outputs the information to '/var/log/authlog-analysis-DATEANDTIME'

# Why this was made:
# This was made for several reasons: Compliance, Incident Response, Legacy & Hybrid Environments, and Security Validation & Auditing

LOGFILE="/var/log/auth.log"
REPORT="/var/log/authlog-analysis-$(date '+%Y%m%d-%H%M%S').txt"

if [ ! -f "$LOGFILE" ]; then
  echo "[!] Log file not found: $LOGFILE"
  exit 1
fi

echo "=== Log Analysis Report ===" > "$REPORT"
echo "Log File: $LOGFILE" >> "$REPORT"
echo "Generated: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# Count total failed logins
echo "[+] Total failed SSH login attempts:" >> "$REPORT"
grep "Failed password" "$LOGFILE" | wc -l >> "$REPORT"
echo "" >> "$REPORT"

# Top 5 offending IPs
echo "[+] Top 5 IPs with failed logins:" >> "$REPORT"
grep "Failed password" "$LOGFILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -5 >> "$REPORT"
echo "" >> "$REPORT"

# Usernames attempted
echo "[+] Top usernames attempted:" >> "$REPORT"
grep "Failed password" "$LOGFILE" | awk '{print $(NF-5)}' | sort | uniq -c | sort -nr | head -5 >> "$REPORT"
echo "" >> "$REPORT"

# Successful logins
echo "[+] Recent successful logins:" >> "$REPORT"
grep "Accepted password" "$LOGFILE" | tail -n 10 >> "$REPORT"
echo "" >> "$REPORT"

# Show most recent sudo activity
echo "[+] Recent sudo usage:" >> "$REPORT"
grep "sudo" /var/log/auth.log | tail -n 10 >> "$REPORT"
echo "" >> "$REPORT"

# Output complete
echo "[✓] Analysis complete. Report saved to $REPORT"