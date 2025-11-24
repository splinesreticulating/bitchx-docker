# BitchX with Osiris Script in Docker

This project provides a secure Docker container running BitchX IRC client with the Osiris script pre-loaded.

## Quick Start

1. **Run the launcher script:**
   ```bash
   ./start-bitchx.sh
   ```

2. **Or use Docker Compose directly:**
   ```bash
   # Build and start
   docker compose up -d
   
   # Attach to the running session
   docker compose attach bitchx
   ```

**Default Server**: `irc.choopa.net` (reliable EFnet server)

## EFnet Servers

The container comes pre-configured with multiple EFnet servers:

### Primary Servers
- `irc.choopa.net` (default)
- `irc.mzima.net`
- `irc.prison.net`
- `irc.sekure.us`

### Regional Servers
- **US West**: `irc.west.gblx.net`, `irc.easynews.com`
- **Europe**: `irc.inet.no`, `irc.port80.se`, `irc.homelien.no`
- **Nordic**: `irc.inet.tele.dk`, `irc.du.se`

### Alternative Ports
If port 6667 is blocked, try: 6660-6669, 7000

### Server Switching
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

2. **Build the container:**
   ```bash
   docker compose build
   ```

3. **Run BitchX:**
   ```bash
   docker compose run --rm bitchx
   ```

## What's Included

- **BitchX 1.3** - Compiled from source with SSL support
- **Osiris Script** - Pre-configured and ready to use
- **Secure User Mapping** - Runs as your user ID for proper file permissions
- **Persistent Configuration** - Your settings are saved in the `./config` directory

## Configuration

- **Script Location**: `/home/mute/osiris/`
- **BitchX Config**: `./config/.BitchX/` (mounted volume)
- **Default Nickname**: `mute`

## Container Details

- **Base Image**: Debian Bookworm Slim
- **User**: mute (mapped to your UID/GID)
- **Entry Point**: `/usr/local/bin/BitchX`
- **Default Args**: `-n mute`

## Troubleshooting

If you encounter permission issues, make sure your UID/GID are set correctly:

```bash
export UID=$(id -u)
export GID=$(id -g)
docker compose up -d
```

To stop the container:

```bash
docker compose down
```

## Osiris Script Features

The Osiris script includes:
- Enhanced IRC interface with custom themes
- Advanced channel management
- Script automation and aliases
- Sound support (MP3/WAV players)
- Custom status bars and formatting
- Much more!

For detailed Osiris documentation, see: `scripts/osiris/README.FIRST`