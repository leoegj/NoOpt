# TODO

## Multi-path hiding

Status: implemented.

Current behavior:

- `target_path` remains available for a legacy single path.
- `target_paths` accepts comma-separated paths.
- The KernelSU wrapper accepts one path per line in `target_path.conf`.
- Each existing path is resolved to a `(dev, inode)` pair at module load time.
- Missing paths are skipped; loading fails only if no configured path exists.

Follow-up ideas:

- Add duplicate target detection.
- Add a runtime debug log that prints the number of hidden entries removed from
  each `getdents64` buffer.

## Scoped hiding / allowlist

Current status: hiding is global. Any process that reaches the hooked kernel
paths sees the target as missing.

Planned direction:

- Add an allowlist for UIDs, process names, or both.
- Let trusted apps or shell/root still access the file while hiding it from
  other apps.
- Keep the default demo behavior simple, but document the risk clearly.
