# BitchX Docker

Containerized BitchX IRC client (version 1.3) with Osiris script pre-loaded and configured for EFnet.

## Quick Start

```bash
./bx.sh start      # Build and start BitchX
./bx.sh attach     # Attach to session
```

**Detach**: `Ctrl+P, Ctrl+Q` (BitchX keeps running)

## Commands

```bash
./bx.sh start      # Build and start container
./bx.sh attach     # Attach to running session
./bx.sh stop       # Stop container
./bx.sh status     # Check if running
```

## Workflow

1. `./bx.sh start` - Builds and starts BitchX with Osiris loaded
2. Use BitchX as normal
3. `Ctrl+P, Ctrl+Q` - Detach to shell (BitchX keeps running)
4. `./bx.sh attach` - Reattach to same session
5. `/quit` or `./bx.sh stop` - Stop BitchX

## Configuration

Default settings:
- **Nickname**: `You`
- **Realname**: `First Last`
- **Default Server**: `irc.choopa.net` (EFnet)

Config files (persistent):
- `config/.ircrc` - Startup commands, loads Osiris
- `config/.BitchX/` - BitchX configuration
- `osiris-config/` - Osiris themes, formats, modules

See `osiris-config/README.FIRST` for Osiris documentation.

## EFnet Servers

Default: `irc.choopa.net`

Switch servers in BitchX: `/server irc.mzima.net`
