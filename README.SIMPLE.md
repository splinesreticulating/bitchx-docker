# BitchX Docker - Simplified Version

A clean, simple solution for running BitchX in Docker with proper detach/attach support.

## How It Works

**The key insight:** Run BitchX inside a **tmux session** within the container.

- BitchX runs in a persistent tmux session named `bitchx`
- The container stays running in the background
- Use `docker exec` to attach to the tmux session
- Use standard tmux detach (Ctrl+B, then D) - rock solid
- No weird Docker attach/detach issues
- BitchX's `/detach` command is safely overridden with an alias

## Quick Start

```bash
# Start BitchX (builds and runs container)
./bx-start

# Attach to BitchX
./bx-attach

# Detach from BitchX
# Press: Ctrl+B then D (standard tmux)
```

## That's It!

No complex scripts, no entrypoint gymnastics, no Docker attach issues.

## Files

**New simplified files:**
- `Dockerfile.simple` - Clean multi-stage build
- `compose.simple.yaml` - Simple compose config
- `startup.sh` - Container entrypoint (sets up Osiris, starts tmux)
- `bx-start` - Start the container
- `bx-attach` - Attach to BitchX session

**Volumes (same as before):**
- `./config/.BitchX/` - BitchX settings (persisted)
- `./osiris-config/` - Your Osiris script customizations (persisted)
- `./config/.ircrc` - Auto-loads Osiris on startup (persisted)

## What Changed?

### Before (Complex)
- Multiple overlapping scripts (start-bitchx.sh, bitchx.sh, bx.sh, launch-bx.sh, entrypoint.sh, setup-osiris.sh)
- Used `docker compose attach` which has issues with terminal handling
- Had to use Ctrl+P, Ctrl+Q to detach (non-standard)
- BitchX's `/detach` command would break the session
- Complex initialization flow

### After (Simple)
- Two scripts: `bx-start` and `bx-attach`
- Uses `docker exec` to attach to tmux session (standard pattern)
- Standard tmux detach (Ctrl+B, D)
- BitchX's `/detach` is overridden with a helpful message
- Simple startup flow: first-run setup → launch tmux → run BitchX

## How /detach is Handled

The startup script creates `~/.ircrc` with:

```
alias detach echo Use Ctrl+B then D to detach from tmux safely
```

This overrides BitchX's `/detach` command so typing it just shows a helpful message instead of breaking your session.

## Advanced Usage

```bash
# Stop BitchX
docker compose -f compose.simple.yaml down

# Rebuild from scratch
docker compose -f compose.simple.yaml build --no-cache

# View logs
docker compose -f compose.simple.yaml logs -f

# Execute command in container
docker exec -it bitchx bash

# Manual tmux operations
docker exec -it bitchx tmux list-sessions
docker exec -it bitchx tmux kill-session -t bitchx
```

## Migration from Old Setup

If you're migrating from the complex version:

1. Your config and osiris-config volumes are compatible - no changes needed
2. Stop the old container: `docker compose down`
3. Start the new one: `./bx-start`
4. Your settings and customizations will be preserved

## Why This is Better

1. **Standard pattern** - tmux in Docker is a well-known, battle-tested approach
2. **Simpler** - 2 user scripts instead of 6
3. **More robust** - No Docker attach/detach issues
4. **Easier to debug** - Less moving parts
5. **Safe /detach** - Overridden with an alias, can't break the session
6. **Better UX** - Standard tmux shortcuts everyone knows

## Troubleshooting

**Container not running?**
```bash
./bx-start
```

**Can't attach?**
```bash
# Check if container is running
docker ps | grep bitchx

# If not, start it
./bx-start
```

**Want to restart BitchX without rebuilding?**
```bash
docker compose -f compose.simple.yaml restart
./bx-attach
```
