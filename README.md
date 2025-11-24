# BitchX Docker

A containerized BitchX IRC client (version 1.3) with Osiris script pre-loaded and configured for EFnet.

## Quick Start

```bash
./bx.sh start
```

## Commands

```bash
./bx.sh attach     # Attach to running BitchX session
./bx.sh stop       # Stop BitchX container
./bx.sh status     # Show session status
./bx.sh exec <cmd> # Execute IRC command
```

## Features

- ✅ **BitchX 1.3** with SSL support
- ✅ **Osiris script** pre-loaded with themes and formats
- ✅ **EFnet servers** configured and ready to connect
- ✅ **Docker attach/detach** with `Ctrl+P, Ctrl+Q`
- ✅ **Persistent configuration** via volume mounts
- ✅ **User ID mapping** for proper file permissions

## Workflow

1. **Start**: `./bx.sh start` → builds, starts container, launches BitchX
2. **Use**: Full BitchX with Osiris script loaded
3. **Detach**: `Ctrl+P, Ctrl+Q` → back to shell, BitchX keeps running
4. **Reattach**: `./bx.sh attach` → back to BitchX session
5. **Stop**: `./bx.sh stop` or `/quit` in BitchX

## Recovery

If attach/detach breaks:
```bash
docker compose restart
./bx.sh attach
```

## Architecture

- **Multi-stage Docker build** compiling BitchX with SSL support
- **Container user mapping** for proper file permissions
- **Volume mounts** for persistent configuration
- **Docker attach/detach** for session management

## Files

- `bx.sh` - Main launcher script
- `compose.yaml` - Docker Compose configuration
- `Dockerfile` - Multi-stage build definition
- `entrypoint.sh` - Container entrypoint
- `launch-bx.sh` - BitchX launcher script
- `config/.ircrc` - IRC configuration (loads Osiris)
- `osiris-config/` - Osiris script with themes and formats

## EFnet Servers

The container comes pre-configured with multiple EFnet servers:

### Primary Servers
- `irc.choopa.net` (default)
- `irc.mzima.net`
- `irc.prison.net`

### Regional Servers
- **US West**: `irc.west.gblx.net`, `irc.easynews.com`
- **Europe**: `irc.inet.no`, `irc.port80.se`, `irc.homelien.no`
- **Nordic**: `irc.inet.tele.dk`, `irc.du.se`

### Alternative Ports
If port 6667 is blocked, try: 6660-6669, 7000

## Server Switching

In BitchX, you can switch servers with:
```
/server irc.choopa.net
/server irc.mzima.net
# etc...
```

## Manual Setup

If you prefer to run it manually:

1. **Set your user ID (for file permissions):**
```bash
export UID=$(id -u)
export GID=$(id -g)
```

2. **Build container:**
```bash
docker compose build
```

3. **Run BitchX:**
```bash
docker compose run --rm bitchx
```

## Configuration

- **Script Location**: `/home/mute/osiris/`
- **BitchX Config**: `./config/.BitchX/` (mounted volume)
- **Default Nickname**: `mute`
- **Default Realname**: `Screaming Mute`

## Osiris Script Features

The Osiris script includes:
- Enhanced IRC interface with custom themes
- Advanced channel management
- Script automation and aliases
- Sound support (MP3/WAV players)
- Custom status bars and formatting
- Much more!

For detailed Osiris documentation, see: `scripts/osiris/README.FIRST`