#!/usr/bin/env bash

LABEL="org.custom.kanata"
PLIST="/Library/LaunchDaemons/org.custom.kanata.plist"

echo "Stopping $LABEL..."
sudo launchctl bootout system/$LABEL 2>/dev/null || true

echo "Starting $LABEL..."
sudo launchctl bootstrap system "$PLIST"
sudo launchctl kickstart -k system/$LABEL

echo
echo "Status:"
sudo launchctl print system/$LABEL | grep -E 'state =|pid =|last exit'
