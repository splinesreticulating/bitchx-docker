#!/bin/bash
# Launch BitchX with proper configuration

set -euo pipefail

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

# BitchX's -s flag enables SSL/TLS for every server loaded after it. The
# server list lives in the persistent config mount, so an absent optional file
# is not accidentally created as a directory by Compose.
server_file="$HOME/.BitchX/.ircservers"
if [ -s "$server_file" ]; then
    exec BitchX -n "${NICK:-you}" -s -r "$server_file" "$@"
else
    exec BitchX -n "${NICK:-you}" -s "${IRC_SERVER:-irc.efnet.org:6697}" "$@"
fi
