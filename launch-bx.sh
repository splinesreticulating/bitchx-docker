#!/bin/bash
# Launch BitchX with proper configuration

# Detect if we're running outside the Docker container
if [ ! -f "/.dockerenv" ]; then
    cat << 'EOF'
ERROR: This script should not be run directly!

This script is designed to run inside the Docker container.

To start BitchX properly:
  1. ./bx.sh start     # Start the container
  2. ./bx.sh attach    # Attach to BitchX session

To detach without stopping: Ctrl+P, Ctrl+Q
To stop: ./bx.sh stop

See ./bx.sh help for more options.
EOF
    exit 1
fi

export TERM=xterm-256color

# Use custom server file if available
if [ -f "$HOME/.ircservers" ]; then
    exec BitchX -n ${NICK:-you} -N -r $HOME/.ircservers "$@"
else
    exec BitchX -n ${NICK:-you} -N "$@"
fi
