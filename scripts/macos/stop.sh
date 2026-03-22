#!/usr/bin/env bash

LABEL="system/org.custom.kanata"
PLIST="/Library/LaunchDaemons/org.custom.kanata.plist"

echo "--- Stopping background daemon ---"
# bootout is the most thorough way to stop it and unregister it temporarily
sudo launchctl bootout "$LABEL" 2>/dev/null || echo "Service wasn't running."

# Optional: Kill any orphaned kanata processes just in case
sudo pkill -9 kanata 2>/dev/null || true

echo "--- Checking Binary Path ---"
# Extract the binary path from your plist to make sure we run the right one
BINARY_PATH=$(sudo defaults read "${PLIST%.*}" ProgramArguments | sed -n '2p' | tr -d '", ')

if [ -z "$BINARY_PATH" ]; then
    echo "Error: Could not find ProgramArguments in $PLIST"
    exit 1
fi

echo "--- Ready for Manual Troubleshooting ---"
echo "Run the following command to see live errors and trigger macOS permission prompts:"
echo ""
echo "sudo $BINARY_PATH --cfg ./your_config.kbd" 
echo ""
echo "Note: Keep this terminal open. If it still says 'Not Permitted', watch for a System Settings popup."
