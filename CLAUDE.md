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
3. Container runs `tail -f /dev/null` to keep container alive
4. BitchX is started manually via `docker compose exec` or launcher scripts
5. Osiris script is loaded automatically via `.ircrc` when BitchX starts
6. Users attach directly to the BitchX process via Docker's attach mechanism

## Common Commands

### Starting BitchX
```bash
# Quick start (builds, starts container, launches BitchX)
./start-bitchx.sh

# Manual start
export UID=$(id -u)
export GID=$(id -g)
docker compose up -d
docker compose exec bitchx /home/mute/launch-bx.sh
```

### Session Management
```bash
# Using the session manager
./bitchx.sh start      # Start BitchX (builds, starts container, launches BitchX)
./bitchx.sh attach     # Attach to running BitchX session
./bitchx.sh status     # Check session status
./bitchx.sh stop       # Stop session
./bitchx.sh exec '<cmd>' # Execute IRC command

# Direct Docker commands
docker compose up -d                                # Start container
docker compose attach bitchx                            # Attach to running BitchX
docker compose down                                  # Stop container
```

### Detaching from BitchX
- **Recommended**: Use `Ctrl+P, Ctrl+Q` to detach from Docker session safely
- **Alternative**: Just close your terminal - BitchX keeps running
- **Avoid**: BitchX's `/detach` command (not needed with Docker attach)
- **Recovery**: If session breaks, run `docker compose restart` and reattach with `./bitchx.sh attach`

### Building
```bash
# Build the image
docker compose build

# Rebuild from scratch
docker compose build --no-cache
```

### Accessing the Container
```bash
# Execute commands in running container
docker compose exec bitchx bash

# Launch BitchX inside container
docker compose exec bitchx /home/mute/launch-bx.sh

# Attach to running BitchX session
docker compose attach bitchx
```

## Key Files

### Entry Scripts
- `start-bitchx.sh` - Primary launcher (sets UID/GID, builds, starts, launches BitchX)
- `bitchx.sh` - Session manager with attach/detach/exec commands
- `bx.sh` - Alternative launcher with instructions
- `entrypoint.sh` - Container entrypoint (kills existing processes, runs tail)
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
- The compose.yaml uses `command: ["tail", "-f", "/dev/null"]` to keep the container alive
- BitchX runs as a process started via `docker compose exec` or launcher scripts
- This allows attaching/detaching from BitchX without stopping the container
- The BitchX process persists even when users detach from Docker session

## IRC Server Configuration

To connect to a different server in BitchX:
```
/server irc.choopa.net
/server irc.mzima.net
```

Alternative ports if 6667 is blocked: 6660-6669, 7000
