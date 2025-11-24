# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitchX Docker provides a containerized BitchX IRC client (version 1.3) with the Osiris script pre-loaded and configured. The setup uses Docker Compose with user ID mapping to ensure proper file permissions for persistent configuration.

## Architecture

**Key Design**: BitchX runs as PID 1 (main container process), enabling proper attach/detach with `Ctrl+P, Ctrl+Q`. This prevents duplicate instances when reattaching.

**Flow**: `entrypoint.sh` → `launch-bx.sh` → BitchX as PID 1. Osiris auto-loads via `config/.ircrc`. Container stops when BitchX exits.

**Build**: Multi-stage build compiles BitchX with SSL in builder stage, then creates minimal runtime image. UID/GID from `.env` (default: 1003/1003) ensures correct file permissions.

## Usage

```bash
./bx.sh start      # Build and start
./bx.sh attach     # Attach to session (Ctrl+P, Ctrl+Q to detach)
./bx.sh stop       # Stop container
./bx.sh status     # Check if running
```

## Key Files

**Scripts**: `bx.sh` (main manager), `entrypoint.sh` (container entrypoint), `launch-bx.sh` (BitchX launcher)

**Config**: `.env` (UID/GID), `compose.yaml`, `Dockerfile`, `config/.ircrc` (loads Osiris), `config/.bitchxrc` (BitchX config)

**Osiris**: `osiris-config/os.bx` (main script), `osiris-config/sets/v.custom` (CTCP VERSION spoofing), themes/formats/modules subdirectories

## Technical Notes

- BitchX compiled with `--with-ssl --with-plugins`
- `stdin_open` and `tty` enabled for interactive use
- Session persists when detached - no duplicate instances
- Fix permissions if needed: `sudo chown -R $(id -u):$(id -g) config/ osiris-config/`
- Rebuild from scratch: `docker compose build --no-cache`
