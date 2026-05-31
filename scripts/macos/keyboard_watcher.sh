#!/bin/bash

# look for my keyboard and if it's there then disable the default kanata profile and ensure the keyboard one is set up 
system_profiler SPBluetoothDataType | grep "D1:00:77:8B:CE:22" && $HOME/.config/kanata/scripts/macos/stop.sh
