# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitchX Docker provides a containerized BitchX IRC client (version 1.3) with the Osiris script pre-loaded and configured. The setup uses Docker Compose with user ID mapping to ensure proper file permissions for persistent configuration.

## Architecture

### Multi-Stage Docker Build
- **Builder stage**: Compiles BitchX from source with SSL support using static linking for OpenSSL libraries
- **Final stage**: Minimal Debian Bookworm runtime with only necessary libraries (libssl3, libncurses6)
- User ID/Group ID are passed as build arguments to create a matching user inside the container

### Container User Mapping
The container runs as user `mute` with UID/GID set from environment variables. This ensures:
- Files created in mounted volumes have correct ownership
- Configuration persists with proper permissions
- `.env` file contains the UID/GID values (defaults: 1003/1003)

### Volume Mounts
- `./config` → `/home/mute/.BitchX` - BitchX configuration and persistent data
- `./osiris-config` → `/home/mute/osiris` - Osiris script and themes
- `./config/.ircrc` → `/home/mute/.ircrc` - IRC startup commands (loads Osiris)
- `./launch-bx.sh` → `/home/mute/launch-bx.sh` - BitchX launcher inside container

### Initialization Flow
1. Container starts with `entrypoint.sh`
2. Kills any existing BitchX processes to prevent duplicates
3. BitchX launches as the main container process via `launch-bx.sh`
4. Osiris script is loaded automatically via `.ircrc` when BitchX starts
5. Users attach/detach using `docker compose attach` and `Ctrl+P, Ctrl+Q`
6. When BitchX exits (via `/quit`), the container stops automatically

## Common Commands

### Starting BitchX
```bash
# Quick start with session manager (builds, starts container)
./bx.sh start

# Simple start (just starts container, BitchX auto-launches)
./bx-start

# Manual start
export UID=$(id -u)
export GID=$(id -g)
docker compose up -d   # BitchX starts automatically
```

### Session Management
```bash
# Using the session manager
./bx.sh start      # Start BitchX (builds, starts container with BitchX)
./bx.sh attach     # Attach to running BitchX session
./bx.sh status     # Check session status
./bx.sh stop       # Stop session (stops container)
./bx.sh exec '<cmd>' # Execute IRC command

# Alternative launcher scripts
./bx-start         # Start container (BitchX auto-launches)
./bx-attach        # Attach to running BitchX session

# Direct Docker commands
docker compose up -d         # Start container (BitchX auto-starts)
docker compose attach bitchx # Attach to BitchX session
docker compose down          # Stop container
```

### Detaching from BitchX
- **Recommended**: Use `Ctrl+P, Ctrl+Q` to detach from Docker session safely
- **Alternative**: Just close your terminal - BitchX keeps running
- **Avoid**: BitchX's `/detach` command (not needed with Docker attach)
- **Recovery**: If session breaks, run `docker compose restart` and reattach with `./bx-attach`
- **Important**: BitchX runs as the main container process, so `docker compose attach` will always reconnect to the same session. No more duplicate instances!
- **Note**: If you `/quit` BitchX, the container will stop. Restart with `./bx.sh start` or `./bx-start`

### Building
```bash
# Build the image
docker compose build

# Rebuild from scratch
docker compose build --no-cache
```

### Accessing the Container
```bash
# Attach to running BitchX session
docker compose attach bitchx

# Execute commands in running container (opens new shell)
docker compose exec bitchx bash

# Detach from BitchX session
# Press: Ctrl+P, Ctrl+Q
```

## Key Files

### Entry Scripts
- `bx.sh` - Main session manager (start/attach/stop/status/exec commands)
- `bx-start` - Simple launcher (sets UID/GID, starts container)
- `bx-attach` - Attach to running BitchX session
- `entrypoint.sh` - Container entrypoint (kills existing processes, launches BitchX)
- `launch-bx.sh` - BitchX launcher script (sets IRCNAME, starts BitchX)

### Configuration
- `.env` - Environment variables for UID/GID mapping
- `compose.yaml` - Docker Compose service definition
- `Dockerfile` - Multi-stage build definition
- `efnet-servers.txt` - List of EFnet servers
- `config/.ircrc` - Auto-loads Osiris script on BitchX startup
- `config/.bitchxrc` - BitchX configuration (created by BitchX)
- `BitchX.doc` - Official BitchX documentation (in main folder)

### Osiris Script
- `osiris-config/os.bx` - Main Osiris script file
- `osiris-config/.osiris.default` - Osiris format configuration (loaded by os.bx)
- `osiris-config/default` - Osiris setup script (displays banners, copies .osiris.default)
- `osiris-config/themes/` - Visual themes for BitchX interface
- `osiris-config/formats/` - Message format templates
- `osiris-config/modules/` - Additional script modules

## Development Notes

### Modifying the Build
- BitchX is compiled with `--with-ssl --with-plugins` flags
- SSL libraries are statically linked (`LDFLAGS="-Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic"`)
- Changing build options requires modifying `Dockerfile` and rebuilding with `--no-cache`

### User ID Conflicts
If file permissions are incorrect:
1. Update `.env` with correct UID/GID values
2. Rebuild: `docker compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)`
3. Fix existing file ownership: `sudo chown -R $(id -u):$(id -g) config/ osiris-config/`

### Default Server
The default IRC server is `irc.choopa.net` (EFnet). Full server list is in `efnet-servers.txt`.

### Container Architecture
- BitchX runs as the main container process (via entrypoint.sh → launch-bx.sh)
- Container has stdin_open and tty enabled for interactive use
- Users attach/detach with `docker compose attach` and `Ctrl+P, Ctrl+Q`
- The BitchX session persists when detached - no duplicate instances
- When BitchX exits, the container stops automatically

## IRC Server Configuration

To connect to a different server in BitchX:
```
/server irc.choopa.net
/server irc.mzima.net
```

Alternative ports if 6667 is blocked: 6660-6669, 7000
