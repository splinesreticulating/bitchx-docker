# Upgrade to Simplified Version

## Side-by-Side Comparison

### Old (Complex) Setup
```
Scripts: 6 files
- start-bitchx.sh
- bitchx.sh
- bx.sh
- launch-bx.sh
- entrypoint.sh
- setup-osiris.sh

Attach: docker compose attach bitchx
Detach: Ctrl+P, Ctrl+Q (weird!)
/detach: BREAKS THE SESSION ⚠️
```

### New (Simple) Setup
```
Scripts: 2 files
- bx-start
- bx-attach

Attach: ./bx-attach (uses docker exec + tmux)
Detach: Ctrl+B, D (standard tmux)
/detach: Safely overridden with alias
```

## Migration Steps

Your existing config and scripts are preserved - no data loss!

```bash
# 1. Stop old container
docker compose down

# 2. Start new version
./bx-start

# 3. Attach to BitchX
./bx-attach

# 4. Test detach/attach
# Press Ctrl+B then D to detach
./bx-attach   # re-attach
```

## What Happens to Your Data?

All preserved! Both versions use the same volumes:
- `./config/.BitchX/` - Your BitchX settings
- `./osiris-config/` - Your Osiris customizations
- `./config/.ircrc` - Auto-load config

## Rollback

If you need to go back:

```bash
# Stop new version
docker compose -f compose.simple.yaml down

# Start old version
docker compose up -d
docker compose attach bitchx
```

## Clean Start (Optional)

If you want to try the new version with a fresh setup:

```bash
# Backup current config
cp -r config config.backup
cp -r osiris-config osiris-config.backup

# Clean start
rm -rf config osiris-config
mkdir -p config/.BitchX

# Start new version
./bx-start
```

## After Migration

You can delete these old files if desired:
- start-bitchx.sh
- bitchx.sh
- bx.sh
- launch-bx.sh
- entrypoint.sh
- setup-osiris.sh
- Dockerfile (replaced by Dockerfile.simple)
- compose.yaml (replaced by compose.simple.yaml)
