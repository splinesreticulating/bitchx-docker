#!/bin/bash

# BitchX Docker Session Manager
# Single script for all BitchX Docker operations

CONTAINER_NAME="bitchx_session"

show_help() {
    echo "BitchX Docker Session Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start      - Build, start container, and launch BitchX"
    echo "  attach     - Attach to running BitchX session"
    echo "  stop       - Stop BitchX container"
    echo "  status     - Show session status"
    echo "  exec <cmd> - Execute command in BitchX"
    echo "  help       - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start           # Start BitchX"
    echo "  $0 attach          # Attach to running session"
    echo "  $0 exec '/scr-bx'   # Send scr-bx command"
    echo "  $0 exec '/load ~/osiris/os.bx'  # Reload osiris"
}

check_container() {
    if ! docker compose ps --format "table {{.Name}}" | grep -q "$CONTAINER_NAME"; then
        echo "❌ BitchX container is not running"
        echo "   Use '$0 start' to start it"
        return 1
    fi
}

attach_session() {
    if check_container; then
        echo "🔗 Attaching to BitchX session..."
        echo "   Use Ctrl+P, Ctrl+Q to detach"
        
        # Simple check: if BitchX is running, attach to it
        # If not running, start new one
        if docker compose exec bitchx sh -c 'pgrep -f BitchX >/dev/null'; then
            echo "✅ Found existing BitchX session, connecting..."
            docker compose exec bitchx /home/mute/launch-bx.sh
        else
            echo "⚠️  No BitchX session found, starting new one..."
            docker compose exec bitchx /home/mute/launch-bx.sh
        fi
    fi
}

start_session() {
    echo "🚀 Starting BitchX with osiris..."
    
    # Set terminal type for proper display
    export TERM=xterm
    
    # Export current user ID and group ID (handle readonly UID)
    MY_UID=$(id -u)
    MY_GID=$(id -g)
    # Only export if not already set (from .env)
    if [ -z "$UID" ]; then export UID=$MY_UID; fi
    if [ -z "$GID" ]; then export GID=$MY_GID; fi
    
    # Build and run the container
    echo "Building BitchX container..."
    docker compose build
    
    echo "Starting BitchX container..."
    docker compose up -d
    
    echo "Launching BitchX with osiris script..."
    docker compose exec bitchx /home/mute/launch-bx.sh
}

stop_session() {
    echo "🛑 Stopping BitchX session..."
    docker compose down
}

show_status() {
    echo "📊 BitchX Session Status:"
    if docker compose ps --format "table {{.Name}}" | grep -q "$CONTAINER_NAME"; then
        echo "   ✅ Container is running"
        echo "   📅 To attach: $0 attach"
        echo "   💬 To execute: $0 exec '<command>'"
    else
        echo "   ❌ Container is not running"
        echo "   🚀 To start: $0 start"
    fi
}

exec_command() {
    local cmd="$1"
    if [ -z "$cmd" ]; then
        echo "❌ Error: No command specified"
        echo "   Usage: $0 exec '<command>'"
        echo "   Common commands: scr-bx, load, server, join"
        return 1
    fi
    
    if check_container; then
        echo "📤 Executing: $cmd"
        # Handle special case for scr-bx to avoid detach issues
        if [ "$cmd" = "scr-bx" ]; then
            echo "🔄 Reloading osiris script..."
            docker compose exec "$CONTAINER_NAME" bash -c "/usr/local/bin/BitchX -c 'load ~/osiris/os.bx' -n mute &"
        else
            docker compose exec "$CONTAINER_NAME" bash -c "echo '$cmd' > /proc/\$(pgrep BitchX)/fd/0"
        fi
    fi
}

# Main command handling
case "${1:-help}" in
    attach)
        attach_session
        ;;
    start)
        start_session
        ;;
    stop)
        stop_session
        ;;
    status)
        show_status
        ;;
    exec)
        exec_command "$2"
        ;;
    help|*)
        show_help
        ;;
esac