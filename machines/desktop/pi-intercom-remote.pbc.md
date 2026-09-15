---
id: pbc-pi-intercom-remote
title: "Pi Intercom — Remote Broker Extension"
context: desktop-automation
status: draft
updated: 2026-09-15
tags:
  - pi
  - intercom
  - networking
  - decided
---

# Pi Intercom — Remote Broker Extension

A decision brief for extending `pi-intercom` beyond its current same-machine
IPC boundary so sessions on Desktop and Testbench can exchange targeted messages.

**Audience:** Operator and supervisor reviewing a prototype before production
use. This document names no implementation owner; ownership is assigned during
review.

## Decision

**Single broker on Desktop. Testbench sessions attach to it through an
SSH-forwarded Unix socket.** Decided 2026-09-15, for simplicity.

- Desktop keeps its normal local broker and behaves exactly as it does today.
- Testbench runs no broker of its own. Its sessions reach the Desktop broker.
- When Desktop is asleep or unreachable, Testbench sessions have no intercom,
  including with each other. Accepted: agents are not expected to need
  intercom on Testbench overnight.

Why this and not a bridge between two brokers: `pi-intercom` 0.13.0 has no
broker federation. A client registers with exactly one broker. Keeping a broker
on each machine therefore requires a bridge process that carries sender
identity, reply threading and pending asks across two brokers without looping.
That is real code, and a bridge that loses provenance or threading fails the
success criteria below. The single-broker design needs no changes to
`pi-intercom`, and everything it sets up (the SSH key, the socket forward,
machine-prefixed names) carries over if a bridge is ever built.

Why SSH and not a VPN relay: neither Tailscale nor WireGuard is installed, and
`testbench` is already configured in `~/.ssh/config` (`testbench.local`, user
`ef-tb`) on the same LAN. A VPN adds infrastructure two machines do not need.

## Scope

- 1:1 `send`, `ask`, and `reply` delivery across Desktop and Testbench.
- Testbench sessions visible in the Desktop broker's session list.
- Desktop local-session behavior and UI/API semantics unchanged.
- Encrypted transport over SSH on the private LAN.

## Non-goals

- Public internet exposure or unauthenticated LAN discovery.
- A shared group chat or replacement for Git/issues.
- Remote shell execution, file transfer, or arbitrary RPC.
- Changes to the `pi-intercom` package or its local broker.
- Testbench intercom while Desktop is offline.

## Terms

```pbc:glossary
- term: Desktop broker
  definition: The existing pi-intercom broker on Desktop, listening on ~/.pi/agent/intercom/broker.sock. The only broker in this design.
- term: Forwarded socket
  definition: A Unix socket on Testbench, at the path pi-intercom clients expect, that SSH forwards to the Desktop broker socket.
- term: Stable identity
  definition: A persisted machine/session identity that survives Pi restarts; unlike runtime-only aliases.
- term: Pairing
  definition: The SSH key authorized for the forward. Revoking the key revokes the pairing.
```

## Actors

```pbc:actors
- id: desktop
  name: Desktop Pi sessions
  type: client
  description: Existing local sessions on the machine that hosts the only broker.
- id: testbench
  name: Testbench Pi sessions
  type: client
  description: Sessions on the operator's test machine, attached to the Desktop broker through the forwarded socket.
- id: broker
  name: Desktop broker
  type: service
  description: The unmodified pi-intercom broker; routes messages for sessions on both machines.
- id: operator
  name: Operator
  type: user
  description: Authorizes the SSH key, chooses recipients, and can revoke access.
```

## Rules

```pbc:rules
- id: local-compatibility
  statement: Desktop local IPC remains the default path and continues working when the network or Testbench is unavailable.
  consequence: Testbench is an explicit exception. Its sessions depend on the Desktop broker and the SSH forward, and have no intercom while either is down.
- id: explicit-trust
  statement: Testbench sessions may reach the Desktop broker only through an operator-authorized SSH key.
  consequence: No unauthenticated discovery and no open network listener.
- id: remote-content-is-untrusted
  statement: Desktop Pi sessions treat Testbench-originated messages as untrusted content, never as operator instructions.
  consequence: A remote message may inform or request review, but cannot authorize privileged actions, secret disclosure, or deployment by itself.
- id: encrypted-transport
  statement: Cross-machine traffic travels only inside SSH; plaintext TCP is forbidden.
  consequence: The Desktop broker keeps listening on its local Unix socket only.
- id: identity
  statement: Sessions must be distinguishable by machine, because pi-intercom 0.13.0 SessionInfo carries name, cwd and pid but no machine field.
  consequence: Testbench session names carry a machine prefix until the protocol provides a machine identity.
- id: delivery-semantics
  statement: send/ask/reply threading, pending asks, and disconnected-mailbox behavior are those of the single unmodified broker.
  consequence: No protocol changes are required.
- id: no-testbench-broker
  statement: Testbench must never start its own broker.
  consequence: The prototype depends on the forwarded socket being present; an explicit no-auto-spawn mode remains a production requirement.
- id: least-privilege
  statement: The SSH key is used for the socket forward only, not for shell access or other forwarding.
  consequence: Use a dedicated key restricted to forwarding, and log connection events without message contents.
```

## States

```pbc:states
- id: local-only
  name: Local-only
  description: Desktop broker running, no forward. Desktop intercom works; Testbench has none.
- id: connected
  name: Forward up
  description: Testbench sessions are registered with the Desktop broker and appear in its session list.
- id: desktop-offline
  name: Desktop unavailable
  description: Testbench sessions cannot reach any broker and report intercom unavailable. Desktop is unaffected when it returns.
- id: revoked
  name: Key revoked
  description: The forward can no longer be established and Testbench delivery stops.
```

## Behavior

```pbc:behavior
- id: remote-targeting
  name: Address a session on the other machine
```

```pbc:preconditions
- The Desktop broker is running.
- The SSH forward from Testbench's broker socket path to the Desktop broker socket is established.
- Testbench broker auto-spawn is disabled.
```

```pbc:trigger
- Operator or Pi session lists sessions or sends an intercom message to a session on the other machine.
```

```pbc:outcomes
- The recipient receives the message; the sender's machine is identifiable from its session name.
- `ask` receives a threaded reply or a clear unavailable/timeout result.
- Desktop sessions keep full local intercom if the forward or Testbench fails.
- Forward and broker state is inspectable with a status command.
```

## Verified risks

Both read from the `pi-intercom` 0.13.0 source installed at
`~/.pi/agent/npm/node_modules/pi-intercom`.

1. **Silent split on Testbench.** Clients call `spawnBrokerIfNeeded`
   (`index.ts`), and a starting broker runs `unlinkSync` on its socket path
   (`broker/broker.ts`). If the forward is down when a Testbench session starts,
   that session spawns a local broker, deletes the forwarded socket, and drops
   off the shared session list with no error. The prototype avoids this only
   while the forward remains present. `config.brokerCommand` does not disable
   spawning; an explicit no-auto-spawn mode is required for production. SSH
   can replace a stale socket when the forward comes back
   (`StreamLocalBindUnlink yes`).
2. **No machine identity.** `SessionInfo` (`types.ts`) exposes `name`, `cwd`
   and `pid`. Names can collide across machines and a pid means nothing off
   its own host. Mitigation: machine-prefixed session names on Testbench.

## Prototype status

Verified 2026-09-15:

- Desktop user services maintain the SSH reverse Unix-socket forward and an
  idle RPC sentinel keeps the Desktop broker alive when no interactive session
  is open.
- Testbench has Pi 0.85.0, Node 22.23.2, and `pi-intercom` installed.
- A Testbench Pi RPC session appeared in the Desktop broker's session list.
- A health probe through the forwarded socket returned protocol version 1.
- The temporary RPC session was stopped after verification; the persistent
  sentinel now prevents the default-case broker split while Desktop is online.

Not yet verified: an actual cross-machine `send`, `ask`, and `reply`; reconnect
after sleep; restricted SSH-key behavior; and startup while the forward is down.

## Implementation notes

Prototype implementation:

- **Forward from Desktop** with a remote Unix-socket forward, so the existing
  `testbench` SSH config is reused and the forward lives exactly as long as
  the Desktop side that hosts the broker:
  `ssh -N -R /home/ef-tb/.pi/agent/intercom/broker.sock:/home/blueaz/.pi/agent/intercom/broker.sock testbench`
- Keep the forward running with a user systemd unit that restarts on failure.
- Keep a Desktop idle RPC sentinel running with a second user systemd unit so
  the broker exists before any Testbench client starts.
- Testbench `sshd` must allow stream-local forwarding and have
  `StreamLocalBindUnlink yes`, or a stale socket file blocks reconnection.
- Paths are absolute because the users differ (`blueaz` on Desktop, `ef-tb`
  on Testbench).
- Confirm whether OpenSSH can restrict the dedicated key to this Unix-socket
  forward; if it cannot, record the residual privilege.

## Deferred alternatives

1. **Bridge between two brokers:** keeps a broker on each machine and restores
   Testbench-only intercom during Desktop outages. Revisit only if that case
   turns out to matter in practice.
2. **VPN relay:** worthwhile for more than two machines or off-LAN access.
3. **Native peer transport:** most complex; defer until relay semantics are
   proven.

## Success criteria

- [x] Desktop can list a Testbench Pi session.
- [ ] `send`, `ask`, and `reply` work across machines with preserved threading.
- [ ] Desktop local messaging works with the forward stopped or Testbench off.
- [ ] Testbench never starts its own broker, including when the forward is down.
  The sentinel only prevents the split while Desktop is online; production still
  requires an explicit no-auto-spawn mode.
- [ ] After Desktop sleeps and wakes, the forward re-establishes without manual cleanup.
- [ ] Testbench session names are distinguishable from Desktop names.
  The current distinction is only the displayed cwd; no machine-prefixed naming
  mechanism has been implemented.
- [ ] Revoking the SSH key stops Testbench delivery without reinstalling Pi.
- [ ] No message contents are written to ordinary logs by default.
- [ ] The setup lives outside the `pi-intercom` package, so upstream updates do not overwrite it.
