#!/bin/bash

kanatalayer="$HOME/.config/kanata/scripts/kanata-layer.py"

if [ -z $1 ]
then
	$kanatalayer list
else
	$kanatalayer change -l $1 > /dev/null
fi
