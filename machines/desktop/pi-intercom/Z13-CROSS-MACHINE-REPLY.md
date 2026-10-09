# z13 reply: cross-machine pi-intercom

## Status (2026-10-08)

The shared-broker setup is operational for Desktop, z13, and TestBench. Desktop
hosts the broker and a sentinel; reverse SSH Unix-socket forwards attach z13 and
TestBench to it. The status check reports `OK` for all three hosts.

Verified from z13:

- The active z13 and TestBench Pi sessions both appear on the Desktop broker.
- An `ask` to TestBench returned `TESTBENCH-SHARED-ACK`.
- An `ask` to Desktop returned `DESKTOP-SHARED-ACK`.

TestBench's account is `eftb`; its socket path and forward service use that
account. Dedicated forward keys are stored only on Desktop; only their public
keys are installed remotely with restricted authorized-key options. No private
keys or credentials are in this repository.

## Mac

`mac-mini.local` remains unreachable, so Mac has not been connected yet. The
Mac forward unit and sshd snippet are ready to use once it is reachable and its
SSH access is configured.

## Operational note

Pi-intercom auto-starts a broker if its socket is absent. If a remote forward is
down while Pi starts, a local broker can be spawned and cause a split. The
Desktop sentinel keeps the shared broker alive; `pi-intercom-status` detects
split brokers. After a remote host or forward outage, check status before
assuming sessions have reattached.
