#!/bin/bash

PLIST_NAME="org.custom.kanata.plist"
DEST="/Library/LaunchDaemons/$PLIST_NAME"
LABEL="system/org.custom.kanata"

echo "--- Stopping and removing service ---"

# Stop and unload the service (ignore errors if not loaded)
sudo launchctl bootout "$LABEL" 2>/dev/null || true

# Remove the plist file
if [ -f "$DEST" ]; then
    sudo rm "$DEST"
    echo "Removed $DEST"
else
    echo "No plist found at $DEST, skipping."
fi

# Kill any remaining kanata processes (optional, but ensures fresh start)
echo "--- Killing any remaining kanata processes ---"
sudo pkill kanata 2>/dev/null || echo "No kanata processes running."

echo "--- Cleanup complete ---"

# Optional: show status of any remaining kanata processes
ps aux | grep kanata | grep -v grep || echo "No kanata processes found."
