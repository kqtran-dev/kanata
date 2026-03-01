#!/usr/bin/env bash
set -e

# Define variables for easier maintenance
PLIST_NAME="org.custom.kanata.plist"
DEST="/Library/LaunchDaemons/$PLIST_NAME"
LABEL="system/org.custom.kanata"

echo "--- Applying configuration to $DEST ---"
sudo cp "./$PLIST_NAME" "$DEST"
sudo chown root:wheel "$DEST"
sudo chmod 644 "$DEST"

echo "--- Re-loading service ---"
# bootout stops the process and unregisters the service
sudo launchctl bootout "$LABEL" 2>/dev/null || true

# bootstrap registers the new file
sudo launchctl bootstrap system "$DEST"

# kickstart -k ensures it is actually started (sending SIGKILL if it was already up)
sudo launchctl kickstart -k "$LABEL"

echo "--- Service Status ---"
sudo launchctl print "$LABEL" | grep -E 'state =|pid =|program =|last exit'
