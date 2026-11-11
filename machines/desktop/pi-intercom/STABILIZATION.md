# Cross-machine intercom stabilization

Status: **not release-ready; real restart recovery remains unverified**.
Last audit: 2026-11-11 UTC. Scope: Desktop, Z13, Testbench, Mac Mini.
Read this alongside `CAPA.md` before applying the historical `INSTALL.md`.

## Terminology and ownership

- **Broker keeper/lifecycle:** Desktop infrastructure that keeps the shared broker available independently of interactive agents. A polling health script is not a keeper: health requests do not register sessions, and the broker can exit when sessions/mailbox are empty.
- **Coordination seat:** an interactive agent in `/home/blueaz/Python/project-phoenix` on Desktop. The same directory on Z13 is a different seat, not another broker. Directory names do not identify machines or route messages uniquely.
- **Monitor:** reports protocol health and ownership/registration evidence; must not automatically kill brokers or Pi sessions.

One coordinating agent owns changes; remote agents report findings without independently deploying parallel fixes. Discover live session IDs and confirm hostname/role before messaging. Do not persist runtime session IDs as durable addresses.

## Last observed baseline (not a live status guarantee)

| Host | Package/source | Evidence and outstanding issue |
|---|---|---|
| Desktop | npm 0.18.1, unpinned, local `PI_INTERCOM_NO_AUTO_BROKER` guard | Broker healthy. Installed sentinel service was replaced with Python health poller; durable keeper not established. |
| Z13 | npm 0.16.0, pinned, local env guard | Direct round-trip confirmed. Additional user-service health poller exists. |
| Testbench | npm 0.18.1, unpinned, no env guard | SSH reachable; Pi PID 3446 and local broker child 3171818 observed. Preserve session; actual routing/round-trip still unverified. PIDs are historical only. |
| Mac Mini | local package `local-packages/pi-intercom-attach-only-0.17.1` | Direct round-trip confirmed. Config has `brokerMode: "attach-only"`. Session preserved. |

Mac source lives at `/Users/blueaz/.pi/agent/local-packages/pi-intercom-attach-only-0.17.1`.
Its `index.ts` and `config.ts` exactly matched the clean Desktop checkout
`/home/blueaz/isolated-pi-intercom` at commit
`1e59891e34a4905b3fa8825ce2161237970495d8` (attach-only broker mode),
based on `ddf2881` (0.17.1). Only those two files were compared; this is not a whole-package identity claim.

0.18.1 also documents native SSH cross-machine send, but that transport lacks
cross-machine ask/replyTo support. Do not silently substitute it for the shared-broker topology.

## Verification completed

Isolated tests only; no live brokers restarted or sessions stopped during takeover audit:

- Installed Desktop 0.18.1 client liveness: 2/2 passed.
- Versioned 0.17.1 attach-only checkout config + client liveness: 16/16 passed.
- `intercom.integration.test.ts` test named
  `attach-only mode fails closed without a broker and registers after endpoint recovery`: 1/1 passed.
  It checks absent `broker.pid` during startup without an endpoint, then registration when an externally started test broker appears.

Evidence on Desktop under `~/.local/state/pi-intercom-audit/`:

- `liveness-20261111T013928Z.log`
- `attach-only-baseline-20261111T020821Z.log`
- `attach-only-integration-20261111T020905Z.log`
- `BASELINE.md` (earlier inventory; Mac was offline then)

These do **not** prove real Pi restart, SSH interruption, machine restart,
sleep/wake, or post-established-connection recovery in attach-only mode.

## Required clean-start behavior

1. Desktop broker starts automatically and survives logout/reboot through a tested lifecycle independent of model turns.
2. Desktop-managed SSH reverse Unix-socket forwards reconnect automatically.
3. Remote Pi uses maintained attach-only behavior on both startup and reconnect. If Desktop is absent, it reports unavailable and retries without spawning a competing broker.
4. Sessions register with explicit machine/role identity; the operator can identify the intended coordination seat.
5. Verification includes an addressed message and reply, not just an active unit, existing socket, or health response.

Starting a remote before Desktop must recover when Desktop returns. Ordinary
operator workflow must require no broker kills, socket deletion, or manual
service restarts. This is the acceptance requirement, **not current functionality**.

## Remaining work, in order

1. Preserve settings, package patches, installed units, and rollback artifacts before changes. Reconcile tracked units with installed units; they currently differ.
2. Select one versioned candidate incorporating attach-only behavior; compare against newer fixes before any downgrade/upgrade. No rollout has been approved by passing these isolated tests alone.
3. Add/execute isolated coverage for established connection loss, retry while unavailable without broker creation, and subsequent registration/message recovery.
4. Implement/test the Desktop keeper/lifecycle. Avoid a model-invoking sentinel and do not disable Desktop's necessary broker startup merely because remotes are attach-only.
5. Standardize remote package/config and retire superseded pollers/workarounds in a coordinated window, preserving headless Testbench's session workflow.
6. Correct status diagnostics: report protocol health, local broker presence, and client registration separately. A local broker process alone does not prove client routing; a healthy local broker can also answer a generic health probe.
7. Run the matrix below; retain before/after evidence and rollback on failures.

| Acceptance case | Required on | State |
|---|---|---|
| Fresh Pi startup and close/reopen | All four | Pending |
| Remote starts while Desktop unavailable, then Desktop returns | Z13, Testbench, Mac | Pending |
| Established SSH forward interruption/recovery | Each remote | Pending |
| Desktop broker restart without remote local-broker spawn | All remotes | Pending |
| Sleep/wake or machine reboot | All applicable hosts | Pending |
| Correct machine/seat discovery and message/reply after each case | All four | Pending |

## Update policy

Four installations are not necessarily four versions. Pi itself and intercom are separate update layers.
Pin the selected intercom baseline across all four machines; test candidate updates in isolation,
then batch deployment with a coordinated verification window and rollback version.
Do not use daily unpinned updates or edits inside npm-managed packages as the maintained solution.
Current inventory is **not yet standardized**.

## Unsafe historical artifacts

Do not deploy `pi-intercom-split-cleanup`: automatic remote broker killing contradicts CAPA policy and can trigger respawn loops and socket removal.
`pi-intercom-preflight` alone is insufficient: it neither proves Desktop broker identity nor prevents spawning after later connection loss.
`pi-intercom-unified-sentinel` is a monitor, not a broker keeper; its split classification is insufficient.
The historical Z13 service template combines `Type=simple` with `--daemon`; do not install it as a root/system service. User-service environment variables do not propagate to unrelated Pi sessions.
These artifacts remain historical tracked code pending controlled retirement, not endorsed deployment tools.
