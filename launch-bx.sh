#!/bin/bash

# BitchX with forced terminal detection
export TERM=xterm-256color
stty rows 25 cols 80 2>/dev/null || true

# Set realname via IRCNAME environment variable (BitchX standard)
export IRCNAME="Screaming Mute"

# Use custom server file if it exists
# NOTE: Removed -d flag to prevent auto-connect retry loops
# Users should manually /server after starting BitchX
if [ -f "/home/mute/.ircservers" ]; then
    exec BitchX -n mute -N -r /home/mute/.ircservers "$@"
else
    exec BitchX -n mute -N "$@"
fi
