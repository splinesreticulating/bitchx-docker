#!/bin/bash

# BitchX with Osiris script launcher
# This script starts BitchX with the osiris script loaded

# Set terminal type for proper display
export TERM=xterm

# Export current user ID and group ID (handle readonly UID)
MY_UID=$(id -u)
MY_GID=$(id -g)
# Only export if not already set (from .env)
if [ -z "$UID" ]; then export UID=$MY_UID; fi
if [ -z "$GID" ]; then export GID=$MY_GID; fi

# Build and run the container
echo "Building BitchX container with osiris script..."
docker compose build

echo "Starting BitchX container..."
docker compose up -d

echo "Launching BitchX with osiris script..."
docker compose exec bitchx /home/mute/launch-bx.sh