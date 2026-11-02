# CAPA — Multi-machine pi-intercom broker split / failed Z13 connection

**Status:** Open; Z13 corrective recovery verified
**Scope:** Desktop-hosted pi-intercom broker and remote Pi clients (Z13, Mac, Testbench)
**Owner:** Operator
**Purpose:** Restore cross-machine messaging without repeating the silent local-broker split; retain objective evidence through verification and recurrence checks.

## Problem statement

Remote Pi sessions can start while the SSH-forwarded Desktop broker socket is absent or unavailable. `pi-intercom` may then auto-start a broker on the remote machine. The session appears locally connected but is isolated from the Desktop broker. A later reverse-forward restart does not move an already-connected client to the Desktop broker. The remote broker can also unlink or leave stale socket paths, making unit state an unreliable proxy for end-to-end connectivity.

This is a recurring failure mode, not evidence that a single forward restart corrected the system.

## Current incident evidence (2026-11-01)

- Desktop's Z13 forward repeatedly exited with SSH status 255; earlier journal entries explicitly report `Could not resolve hostname z13.local`, and later entries report `Connection to z13.local closed by remote host`.
- The restart counter reached 78. A later snapshot showed the forward active, but the read-only health tool reported Z13 `SPLIT` because a Z13-local broker was running (PID 9541).
- Z13 showed a Pi intercom broker and two listeners reported at the expected socket pathname. The Z13 session's own note reported a local broker and a roster containing only itself.
- Therefore SSH reachability and a currently active systemd unit do not establish that a Pi client is attached to the Desktop broker. Exact client-to-socket routing remains to be verified.
- The same status tool reported transient Mac/Testbench states that changed on subsequent runs. Treat status output as a timestamped snapshot, not a durable claim.

## Containment and immediate recovery

Perform in order. Preserve logs before clearing/restarting anything. Do not kill broker processes, unlink sockets, restart remote sessions, or change SSH/systemd configuration without the operator's explicit approval.

1. **Record the incident snapshot.** On Desktop, run:
   ```sh
   date -Is
   ~/.dotfiles/machines/desktop/pi-intercom/pi-intercom-status --json
   systemctl --user show pi-intercom-desktop-sentinel.service pi-intercom-z13-forward.service \
     -p Id -p ActiveState -p SubState -p NRestarts -p ExecMainStatus
   journalctl --user -u pi-intercom-z13-forward.service -n 100 --no-pager
   ```
   Save outputs with the incident record. Do not include key material or credentials.
2. **Confirm the Desktop broker first.** It must answer its own protocol health request. If Desktop is `BROKER-DOWN`, stop: repair that boundary before remote work.
3. **Confirm the Z13 forward.** Check the unit and SSH journal, but do not use `active (running)` as the pass criterion. Resolve the actual SSH failure (including hostname resolution or remote close) before proceeding. The required condition is a successful broker-protocol health probe through the Z13 forwarded socket.
4. **Quiesce the isolated Z13 Pi client.** With operator approval, close the affected Pi session normally. Confirm no Z13 Pi clients remain attached to the local broker. Do not indiscriminately kill all Pi or Node processes.
5. **Remove the split only through the documented package/service lifecycle.** With operator approval, stop the orphaned Z13-local pi-intercom broker cleanly so it cannot unlink a live forwarded socket on exit. Do not manually `rm` the socket while either broker/forward may own it. If ownership is ambiguous, stop and collect socket inode/listener evidence first.
6. **Establish and verify the forward before launching Pi.** Confirm Desktop broker health, start/restore the Z13 reverse forward, then perform the protocol health probe through the forwarded socket. If the current `pi-intercom-status` reports `SPLIT` solely because a broker process exists, do not treat that as proof the forwarded health probe failed; use an independent, documented protocol probe and first correct the status tool's ambiguity.
7. **Start one fresh Z13 Pi session only after the forward health probe passes.** Confirm its session appears in the Desktop intercom roster. Send a harmless uniquely worded `send` to the Z13 session and verify receipt/response in both directions. A local `Connected` indicator or SSH TCP success is insufficient.
8. **Re-run status and record the outcome.** Preserve the before/after snapshots, relevant logs, and exact verification time. If the session is still absent, stop; do not repeat the same restart sequence. Return to socket-path/listener ownership diagnosis.

### Recovery result — 2026-11-01

Process times established the startup race: Z13 Pi PID 9447 started at 15:15:10, its local broker PID 9541 at 15:15:12, and the Desktop forward became active at 15:26:52. The existing Pi session was therefore attached to a local broker; bringing the forward up later did not migrate it.

With operator authorization, the Pi process was stopped. Its local broker then exited and unlinked the socket pathname used by the forward, producing `STALE` / `no socket`. Restarting the forward after broker exit restored the socket. The next read-only health check returned `OK` with no local broker. A fresh Z13 Pi session (ID `01a198dc-2d34-73ba-960a-0aaea150bc73`) appeared in the Desktop roster, confirmed hostname `z13`, and replied to a cross-machine intercom ask. The final health check returned Z13 `OK`.

**Disposition:** Immediate Z13 recovery verified. CAPA remains open: preventing local broker auto-spawn and validating the recovery across interruption/sleep-wake have not been completed.

## Corrective actions

| ID | Action | Acceptance evidence | State |
|---|---|---|---|
| C1 | For the active incident, restore the Z13 client only after the Desktop broker and forwarded socket pass protocol-level health checks; retire the local Z13 broker/session in a controlled, operator-approved sequence. | Z13 session visible in Desktop roster and cross-machine reply succeeds; no local broker remained at verification. | Complete for this incident; verified 2026-11-01 |
| C2 | Correct `pi-intercom-status` so it reports separate facts: forward protocol health, local broker presence, and client registration. A remote broker process alone must not mask a successful forwarded-socket health result or be conflated with proof that the current Pi client uses that broker. | Automated tests cover forwarded socket healthy + local broker present, stale forward, split-only, and healthy-only cases. | Open |
| C3 | Improve evidence capture so repeated SSH DNS/remote-close failures are grouped by cause and linked to restart counts; do not silently equate systemd active state with a healthy path. | A single status/incident report contains unit state, restart count, last SSH failure, and protocol-health result. | Open |

## Preventive actions

| ID | Action | Acceptance evidence | State |
|---|---|---|---|
| P1 | Enforce fail-closed remote startup: a remote Pi session must not auto-spawn a local broker when the forwarded Desktop socket is missing. Prefer an upstream-supported no-auto-spawn setting/patch; until available, provide a managed launcher/preflight that refuses to start Pi unless the forwarded socket returns the expected protocol health response. | With the forward stopped, launching the managed remote Pi entry point fails clearly and creates no local broker. | Open |
| P2 | Order recovery/startup as broker → forward → protocol health → remote Pi client. Make this order part of the operator runbook and any managed session launcher. | Reboot/sleep-wake/reconnect test shows remote Pi starts only after health passes. | Open |
| P3 | Make the watchdog distinguish `DOWN`, `STALE`, and `SPLIT` using protocol-level socket checks plus broker ownership evidence. `SPLIT` must alert and require human action; never auto-kill a remote broker or Pi session. | Dry-run and controlled fault-injection demonstrate correct classifications and no destructive action on `SPLIT`. | Open |
| P4 | Add recurring failure evidence to one incident log: timestamped status JSON, forward journal tail, socket inode/listener inventory, and whether a fresh Pi session appears in the Desktop roster. Keep auth material and private session contents out. | At least one completed sleep/wake and one forward-loss/recovery cycle are recorded. | Open |
| P5 | Establish a multi-machine acceptance check before declaring the stack available: health through each forward, session discovery, and bidirectional send/reply. | Z13, Mac, and Testbench independently pass after a cold start and after a simulated forward interruption. | Open |

## Root-cause status

**Confirmed failure class:** local broker auto-spawn can split a remote session from the Desktop broker when the forward is absent at client startup; this mechanism and a prior Testbench occurrence are documented in `../pi-intercom-remote.pbc.md`.

**Confirmed Z13 incident root cause:** Z13 Pi and its local broker started at 15:15:10/15:15:12, before the Desktop forward became active at 15:26:52. The existing client remained attached to the local broker after the forward recovered. When the Pi/local broker exited, broker shutdown unlinked the forwarded socket path; restarting the forward afterward restored it. A fresh Pi session then registered with Desktop and passed an intercom reply test.

**Still open:** the initiating causes of repeated SSH failures (including hostname-resolution and remote-closed errors) are not fully established. Prevention of future local broker auto-spawn and CAPA effectiveness across sleep/wake and forward interruption have not been demonstrated.

## Effectiveness review and closure

Do not close this CAPA when a unit merely becomes active or a one-time session appears. Close only when:

- Corrective actions C1–C3 are complete and verified.
- Preventive actions P1–P5 have passed their stated acceptance evidence.
- Z13 remains on the Desktop roster after at least one forward interruption/recovery and one sleep/wake or reboot cycle, with no local broker split.
- The operator-facing procedure produces an unambiguous pass/fail result without requiring the operator to reconstruct prior incident history.

Any recurrence reopens the CAPA. Append a dated incident record with raw evidence; do not overwrite prior findings or label the issue resolved based on a restart alone.
