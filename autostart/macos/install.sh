#!/usr/bin/env bash
set -e


sudo cp ./org.custom.kanata.plist "/Library/LaunchDaemons/org.custom.kanata.plist"
sudo chown root:wheel "/Library/LaunchDaemons/org.custom.kanata.plist"
sudo chmod 644 "/Library/LaunchDaemons/org.custom.kanata.plist"

sudo launchctl bootout system/org.custom.kanata 2>/dev/null || true
sudo launchctl bootstrap system "/Library/LaunchDaemons/org.custom.kanata.plist"
sudo launchctl kickstart -k system/org.custom.kanata

sudo launchctl print system/org.custom.kanata | grep -E 'state =|pid =|program =|last exit'
