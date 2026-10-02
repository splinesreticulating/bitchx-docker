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
- **Nickname**: `you`
- **Realname**: `You`
- **Default Server**: `irc.efnet.org:6697` (EFnet, TLS)
- **Container UID/GID**: account running `./bx.sh start`

Config files (persistent):
- `config/.ircrc` - Startup commands, loads Osiris
- `config/.ircservers` - Optional custom server list (not committed)
- `config/` - BitchX runtime configuration
- `osiris-config/` - Osiris themes, formats, modules

See `osiris-config/README.FIRST` for Osiris documentation.

Optional environment settings can be placed in `.env`:

```dotenv
USER_NAME=you
NICK=you
IRCNAME=You
IRC_SERVER=irc.efnet.org:6697
RESTART_POLICY=no
```

`./bx.sh start` supplies `BITCHX_HOST_UID` and `BITCHX_HOST_GID`; direct
`docker compose` use falls back to legacy `.env` values named `UID` and `GID`,
then to 1000 when those are unset.

Set `RESTART_POLICY=unless-stopped` for an always-on host. The default `no`
allows `/quit` to leave the container stopped.

## EFnet Servers

Default: `irc.efnet.org:6697`

The launcher always passes BitchX's `-s` flag, including when loading
`config/.ircservers`. Custom entries must therefore use a server's TLS port:

```text
irc.efnet.org:6697
```

To switch interactively, include `-ssl`: `/server -ssl irc.efnet.org:6697`.

> **TLS limitation:** this version of BitchX encrypts the connection but does
> not verify the server certificate or hostname. It protects against passive
> cleartext capture, but not an active man-in-the-middle attack.
