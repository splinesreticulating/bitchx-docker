#!/bin/bash

# Kill any existing BitchX processes to prevent duplicates
pkill -u mute BitchX 2>/dev/null || true

# Launch BitchX as the main process so docker attach works
exec /home/mute/launch-bx.sh