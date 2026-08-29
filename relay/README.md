# relay — cross-machine message drop for agent sessions

`relay` moves a file or a one-line message between this machine and another over
ssh/scp. Nothing else: no git, no daemon, no ledger.

```
relay send <host> <file>       copy a file into that host's inbox
relay send <host> -m "text"    send a one-line message
relay inbox                    list unread here
relay read <n>                 print it, mark read
relay peek <n>                 print without marking read
relay hosts                    ssh hosts known here
```

Messages land as `~/handoffs/inbox/<utc-ts>-from-<host>-<name>`. Read ones move to
`~/handoffs/inbox/read/`. Nothing is ever deleted.

## Install

`stow relay` from `~/.dotfiles`, then ensure `~/.local/bin` is on `PATH`. The
sending side needs an ssh host entry for the target and working key auth; the
receiving side needs nothing but the script.

## Why it lives here and not in operator-control-plane

The ledger repo records claims, evidence, and verification. A message bus is
machine infrastructure, not ledger logic, and `AUTHORITY_BROKER_SPEC.md` already
draws that boundary for the broker. But "not in the ledger repo" must not mean
"unversioned" — an unversioned mechanism is exactly how the uid-971 verifier
container was lost (it ran once on 2026-08-25, was never scripted, and had to be
reconstructed from fingerprints left in evidence records).

## Why it exists

2026-08-28: getting one diagnostic line from z13 to the desktop during a live
dual-3090 sglang OOM took roughly an hour. The session reached for git as the
transport — commit, push, pull — because `~/handoffs/` is a *local* directory on
each machine with nothing syncing it, so a "file drop" there moved zero bytes and
the human became the carrier. ssh already worked in both directions; nothing was
wired to it. See the `desktop-comms-postmortem-2026-08-28` task in the z13 ledger.

## Known limits

- Hub-and-spoke in practice: desktop reaches mac and z13. mac ↔ z13 direct needs a
  host-key conflict resolved on mac (stale entry for 192.168.8.117) and a key
  authorized on mac for z13.
- No notification. A receiving session must be told, or check `relay inbox` at
  session start.
- No tests.
