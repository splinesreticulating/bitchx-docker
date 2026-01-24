#!/bin/bash
# Launch BitchX with proper configuration

export TERM=xterm-256color
export IRCNAME="You"

# Use custom server file if available
if [ -f "/home/you/.ircservers" ]; then
    exec BitchX -n you -N -r /home/you/.ircservers "$@"
else
    exec BitchX -n you -N "$@"
fi
