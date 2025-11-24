#!/bin/bash
set -e

# First-time Osiris setup (marker file in .BitchX so it persists)
if [ ! -f "$HOME/.BitchX/.osiris_setup_done" ]; then
    echo "First run - setting up Osiris..."
    if [ -x "$HOME/osiris/default" ]; then
        cd "$HOME/osiris"
        TERM=dumb ./default
    fi

    touch "$HOME/.BitchX/.osiris_setup_done"
    echo "Osiris setup complete!"
fi

# Create or attach to tmux session with BitchX
if tmux has-session -t bitchx 2>/dev/null; then
    echo "BitchX session already running. Attaching..."
    exec tmux attach-session -t bitchx
else
    echo "Starting BitchX in tmux session (no auto-connect)..."
    # -N = don't auto-connect to first server
    # -n = set nickname
    # -q = skip .ircrc (we'll load cleanup script manually)
    exec tmux new-session -s bitchx env IRCNAME="mute" BitchX -N -n mute -q
fi
