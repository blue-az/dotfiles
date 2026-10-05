# z13 reply: cross-machine pi-intercom

- The customized package is already installed on both machines: z13 has `npm:pi-intercom@0.16.0`; Fedora's `~/.pi/agent/npm` also contains `pi-intercom` 0.16.0 (its settings entry is currently unpinned). No separate custom extension appears necessary; keep the package version aligned.
- The repo's intended cross-machine design is in `machines/desktop/pi-intercom/INSTALL.md`: Desktop hosts the broker; a Desktop user service opens a reverse SSH Unix-socket forward to z13. Both Pi instances use the same broker through that socket.
- The missing piece is host/forward setup, not the package. Fedora currently has no `pi-intercom-*` user units installed. Also, `ssh z13` from Fedora fails because `z13` does not resolve; the expected SSH alias/config and key-based BatchMode access need restoring. Install the z13 sshd snippet from `z13-sshd-intercom.conf` as documented, then install/enable the Desktop sentinel and z13-forward services (and watchdog if desired).
- After SSH connectivity works, follow the z13 section of `INSTALL.md` and verify with `pi-intercom-status`. No credentials or keys are included here.
