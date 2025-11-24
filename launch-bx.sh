#!/bin/bash
# Launch BitchX with proper configuration

export TERM=xterm-256color
export IRCNAME="Screaming Mute"

# Use custom server file if available
if [ -f "/home/mute/.ircservers" ]; then
    exec BitchX -n mute -N -r /home/mute/.ircservers "$@"
else
    exec BitchX -n mute -N "$@"
fi
