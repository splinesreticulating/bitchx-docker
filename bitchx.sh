#!/bin/bash

# BitchX Docker Session Manager
# Handles attach/detach like native BitchX

CONTAINER_NAME="bitchx_session"
SESSION_NAME="bitchx"

show_help() {
    echo "BitchX Docker Session Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  attach     - Attach to running BitchX session"
    echo "  start      - Start new BitchX session"
    echo "  stop       - Stop BitchX session"
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
    if ! docker compose ps | grep -q "$CONTAINER_NAME"; then
        echo "❌ BitchX container is not running"
        echo "   Use '$0 start' to start it"
        return 1
    fi
}

attach_session() {
    if check_container; then
        # Check if BitchX is already running (look for BitchX in process list)
        if docker compose exec bitchx sh -c 'for pid in /proc/[0-9]*/cmdline; do [ -f "$pid" ] && cat "$pid" 2>/dev/null | grep -q BitchX && exit 0; done; exit 1'; then
            echo "🔗 Attaching to existing BitchX session..."
            echo "   Use Ctrl+P, Ctrl+Q to detach"
            docker compose attach "$CONTAINER_NAME"
        else
            echo "🚀 Starting new BitchX session..."
            echo "   Use Ctrl+P, Ctrl+Q to detach"
            docker compose exec bitchx /home/mute/launch-bx.sh
        fi
    fi
}

start_session() {
    echo "🚀 Starting BitchX with osiris..."
    ./start-bitchx.sh
}

stop_session() {
    echo "🛑 Stopping BitchX session..."
    docker compose down
}

show_status() {
    echo "📊 BitchX Session Status:"
    if docker compose ps | grep -q "$CONTAINER_NAME"; then
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