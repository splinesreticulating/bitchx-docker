# Removing BitchX /detach Command (Optional)

The simplified setup overrides `/detach` with an alias, but if you want to completely remove it from BitchX, here's how.

## Option 1: Alias Override (Already Done)

The `startup.sh` creates this in `~/.ircrc`:

```
alias detach echo Use Ctrl+B then D to detach from tmux safely
```

This replaces `/detach` with a helpful message. Should work for most cases.

## Option 2: Patch BitchX Source (Nuclear Option)

If the alias doesn't work or you want to be absolutely sure, patch the source:

### Create the patch file

```bash
cat > disable-detach.patch << 'EOF'
--- a/source/commands.c
+++ b/source/commands.c
@@ -xxx,x +xxx,x @@
 /* Find the line in commands.c that registers "detach" command */
 /* Comment it out or replace with a no-op */
EOF
```

### Modify Dockerfile.simple

Add before the build step:

```dockerfile
# Apply patch to disable /detach
COPY disable-detach.patch /src/
RUN cd /src && patch -p1 < disable-detach.patch
```

### Find the exact code

The BitchX source has the command registered somewhere. You'd need to:

1. Clone the repo: `git clone https://github.com/BitchX/BitchX1.3.git`
2. Search for "detach" in source files: `grep -r "detach" source/`
3. Find where it's registered as a command
4. Comment out or modify that registration

## Option 3: Test if Alias Works

Before going nuclear with source patches:

```bash
# Start BitchX
./bx-start
./bx-attach

# In BitchX, type:
/detach

# If it shows "Use Ctrl+B then D to detach from tmux safely"
# instead of breaking the session, the alias works!
```

## Recommendation

**Stick with the alias approach.** It's simpler and should work fine. The BitchX `/detach` command only causes issues when you're using Docker attach directly. With tmux, even if the alias fails, `/detach` would just detach the tmux session (which is actually safe).

## Why tmux Makes This Less Critical

In the old setup: `/detach` broke Docker's attach mechanism

In the new setup: `/detach` would at worst detach from tmux, which is recoverable with `./bx-attach`

So the risk is much lower now even without removing the command.
