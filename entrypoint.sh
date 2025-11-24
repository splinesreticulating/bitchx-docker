#!/bin/bash

# Kill any existing BitchX processes to prevent duplicates
pkill -u mute BitchX 2>/dev/null || true

# Keep container running without auto-starting BitchX
# Users should manually start with: docker compose exec bitchx /home/mute/launch-bx.sh
exec tail -f /dev/null