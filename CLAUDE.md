# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitchX Docker provides a containerized BitchX IRC client (version 1.3) with the Osiris script pre-loaded and configured. The setup uses Docker Compose with user ID mapping to ensure proper file permissions for persistent configuration.

## Architecture

### Docker Build
Multi-stage build: compiles BitchX with SSL in builder stage, then creates minimal runtime image.
User ID/GID from `.env` (default: 1003/1003) ensures correct file permissions in mounted volumes.

### Volume Mounts
- `./config` → `/home/mute/.BitchX` - Configuration and persistent data
- `./osiris-config` → `/home/mute/osiris` - Osiris script and themes
- `./config/.ircrc` → `/home/mute/.ircrc` - Startup commands (loads Osiris)
- `./launch-bx.sh` → `/home/mute/launch-bx.sh` - BitchX launcher

### How It Works
1. `entrypoint.sh` → `launch-bx.sh` starts BitchX as PID 1
2. Osiris auto-loads via `.ircrc`
3. Attach/detach with `Ctrl+P, Ctrl+Q`
4. Exiting BitchX stops the container

## Common Commands

### Basic Usage
```bash
./bx.sh start      # Build and start BitchX
./bx.sh attach     # Attach to running session
./bx.sh stop       # Stop BitchX container
./bx.sh status     # Check if running
```

### Detaching
Press `Ctrl+P, Ctrl+Q` to detach without stopping BitchX.
Just close your terminal if you prefer - BitchX keeps running.

### Direct Docker Commands
```bash
docker compose up -d         # Start container
docker compose attach bitchx # Attach to session
docker compose down          # Stop container
docker compose restart       # Restart if stuck
```

### Advanced
```bash
docker compose build --no-cache  # Rebuild from scratch
docker compose exec bitchx bash  # Open shell in container
```

## Key Files

### Scripts
- `bx.sh` - Main manager (start/attach/stop/status commands)
- `entrypoint.sh` - Container entrypoint
- `launch-bx.sh` - BitchX launcher (sets TERM, IRCNAME)

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

## Technical Details

### Build Configuration
- BitchX compiled with `--with-ssl --with-plugins`
- SSL libraries statically linked for portability
- Rebuild with `--no-cache` if changing Dockerfile

### User Mapping
UID/GID from `.env` (defaults: 1003/1003) ensures correct file permissions.
Fix permissions if needed: `sudo chown -R $(id -u):$(id -g) config/ osiris-config/`

### Architecture
- BitchX is the main container process (PID 1)
- `stdin_open` and `tty` enabled for interactive use
- Session persists when detached - no duplicate instances
- Container stops when BitchX exits

## IRC Servers

Default: `irc.choopa.net` (EFnet). See `efnet-servers.txt` for more.

Connect to a different server:
```
/server irc.mzima.net
```

Alternative ports: 6660-6669, 7000
