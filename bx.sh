#!/bin/bash
# BitchX Docker Manager

CONTAINER_NAME="bitchx_session"

show_help() {
    cat << EOF
BitchX Docker Manager

Usage: $0 <command>

Commands:
  start      Build and start BitchX container
  attach     Attach to running BitchX session
  stop       Stop BitchX container
  status     Show container status
  help       Show this help

Detach from BitchX: Press Ctrl+P, Ctrl+Q

Examples:
  $0 start    # Start BitchX
  $0 attach   # Attach to session
  $0 stop     # Stop container
EOF
}

check_container() {
    docker compose ps --format "table {{.Name}}" | grep -q "$CONTAINER_NAME"
}

cmd_start() {
    echo "Starting BitchX..."

    # Set GID for user mapping (UID is auto-set by bash)
    export GID=$(id -g)

    # Disable BuildKit on systems without buildx (preserves layer cache)
    DOCKER_BUILDKIT=0 docker compose up -d --build

    echo ""
    echo "BitchX is starting. Attach with: $0 attach"
}

cmd_attach() {
    if ! check_container; then
        echo "Error: BitchX container is not running"
        echo "Start it with: $0 start"
        return 1
    fi

    echo "Attaching to BitchX... (Ctrl+P, Ctrl+Q to detach)"
    docker compose attach bitchx
}

cmd_stop() {
    echo "Stopping BitchX..."
    docker compose down
}

cmd_status() {
    if check_container; then
        echo "BitchX is running"
        echo "Attach with: $0 attach"
    else
        echo "BitchX is not running"
        echo "Start with: $0 start"
    fi
}

# Main command dispatcher
case "${1:-help}" in
    start)  cmd_start ;;
    attach) cmd_attach ;;
    stop)   cmd_stop ;;
    status) cmd_status ;;
    *)      show_help ;;
esac
