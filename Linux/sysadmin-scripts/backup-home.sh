#!/bin/bash

# Im pretty obsessed with backing stuff up so I made this to backup my home folder to my Synology NAS :)
# I modified it to make a few assumptions if you would like to use it

# Config
SOURCE_DIR="/home/$(whoami)"
NAS_HOST="10.0.0.215"
NAS_PATH="/home/janderson/backup"

DEST_DIR="$(whoami)@$NAS_HOST:$NAS_PATH/"
LOGFILE="$HOME/synology-backup-$(date '+%Y%m%d-%H%M%S').log"

# Exclude a few things Im not worried about
EXCLUDES=(
  "--exclude=.cache/"
  "--exclude=Downloads/"
  "--exclude=Trash/"
)

echo "=== Synology Backup: $(date) ===" | tee -a "$LOGFILE"

# Backup over SSH using rsync
rsync -avh --delete "${EXCLUDES[@]}" -e ssh "$SOURCE_DIR/" "$DEST_DIR/" | tee -a "$LOGFILE"


if [ $? -eq 0 ]; then
  echo "[✓] Backup completed successfully at $(date)" | tee -a "$LOGFILE"
else
  echo "[✗] Backup failed at $(date)" | tee -a "$LOGFILE"
fi
