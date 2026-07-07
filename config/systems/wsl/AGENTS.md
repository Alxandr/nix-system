# RTK - Rust Token Killer (Codex CLI)

**Usage**: Token-optimized CLI proxy for shell commands.

## Rule

Always prefix shell commands with `rtk`.

Examples:

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

Exceptions:

Do **NOT** use `rtk` for commands starting with:

- `dotnet test`

## Meta Commands

```bash
rtk gain            # Token savings analytics
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run raw command without filtering
```

## Verification

```bash
rtk --version
rtk gain
which rtk
```

# File truncation safety

If a file unexpectedly becomes zero-length during editing, stop immediately.
Do not attempt recovery or further edits. Tell the user which file was
truncated and wait for them to inspect the situation.
