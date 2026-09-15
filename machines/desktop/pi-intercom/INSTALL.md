# Remote pi-intercom socket forward

This prototype keeps the only pi-intercom broker on Desktop. A user service on
Desktop creates an SSH reverse Unix-socket forward at Testbench's normal broker
path, so Testbench Pi sessions can attach to the Desktop broker without running
a second broker.

## Prerequisites

- `testbench` must resolve through `~/.ssh/config` and accept `BatchMode` SSH.
- Testbench needs Pi 0.85.0 and `pi-intercom` installed. Pi requires Node
  >=22.19.0; on this host the user-local Node 22.23.2 is used.
- The `ef-tb` account must have `~/.pi/agent/intercom/` created before the
  forward starts.
- The Desktop broker must be running before Testbench sessions start.
- Testbench sshd should install `testbench-sshd-intercom.conf` before relying
  on sleep/wake reconnects.

Install the matching Pi and intercom package on Testbench (with the user's
Node 22 on `PATH`):

```sh
ssh testbench 'export PATH="$HOME/.local/bin:$PATH"; pi install npm:pi-intercom@0.13.0'
```

Create the remote socket directory once:

```sh
ssh testbench 'mkdir -p ~/.pi/agent/intercom && chmod 700 ~/.pi/agent ~/.pi/agent/intercom'
```

Install and start the Desktop-side services. The sentinel is required for the
prototype: it keeps a Desktop broker alive even when no interactive Desktop Pi
session is open, preventing Testbench from silently spawning a split broker.

```sh
mkdir -p ~/.config/systemd/user
install -m644 ~/.dotfiles/machines/desktop/pi-intercom/pi-intercom-*.service \
  ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pi-intercom-desktop-sentinel.service
systemctl --user enable --now pi-intercom-testbench-forward.service
```

On Testbench, install the sshd hardening snippet and reload sshd (requires
local sudo access):

```sh
scp ~/.dotfiles/machines/desktop/pi-intercom/testbench-sshd-intercom.conf \
  testbench:/tmp/90-pi-intercom.conf
ssh -t testbench 'sudo install -m644 /tmp/90-pi-intercom.conf /etc/ssh/sshd_config.d/90-pi-intercom.conf && sudo sshd -t && sudo systemctl reload ssh'
```

Inspect it with:

```sh
systemctl --user status pi-intercom-testbench-forward.service
ssh testbench 'stat -c "%F %a" ~/.pi/agent/intercom/broker.sock'
```

The current package still auto-spawns a broker if the forwarded socket is
absent. The Desktop sentinel prevents this split while Desktop is online. Do
not treat that as the production solution: an explicit no-auto-spawn mode is
still required before relying on this across sleep, boot, or network outages.

Stop/disable the prototype with:

```sh
systemctl --user disable --now pi-intercom-testbench-forward.service
```
