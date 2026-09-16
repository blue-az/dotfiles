# Remote pi-intercom socket forward

This prototype keeps the only pi-intercom broker on Desktop. A user service on
Desktop creates an SSH reverse Unix-socket forward at Testbench's normal broker
path, so Testbench Pi sessions can attach to the Desktop broker without running
a second broker.

## Prerequisites

- `testbench` must resolve through `~/.ssh/config` and accept `BatchMode` SSH.
- Testbench needs Pi installed with `pi-intercom@0.13.0`. Pi requires Node
  >=22.19.0; on this host the user-local Node 22.23.2 is used. Keep the
  intercom package version aligned with Desktop; Pi CLI versions may differ
  if their protocol remains compatible.
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

## Mac (same pattern)

`Host mac` in `~/.ssh/config` (`Mac-mini.local`, user `blueaz`). Same Desktop
broker; a second reverse Unix-socket forward. Mac sessions are untrusted
remote content, like Testbench.

```sh
ssh mac 'export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"; pi install npm:pi-intercom@0.13.0'
ssh mac 'mkdir -p ~/.pi/agent/intercom && chmod 700 ~/.pi/agent ~/.pi/agent/intercom'
```

```sh
install -m644 ~/.dotfiles/machines/desktop/pi-intercom/pi-intercom-*.service \
  ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pi-intercom-mac-forward.service
```

Mac sshd snippet (local sudo on the Mac):

```sh
scp ~/.dotfiles/machines/desktop/pi-intercom/mac-sshd-intercom.conf \
  mac:/tmp/90-pi-intercom.conf
ssh -t mac 'sudo install -m644 /tmp/90-pi-intercom.conf /etc/ssh/sshd_config.d/90-pi-intercom.conf && sudo sshd -t && sudo launchctl kickstart -k system/com.openssh.sshd'
```

Inspect:

```sh
systemctl --user status pi-intercom-mac-forward.service
ssh mac 'stat -f "%HT %Lp" ~/.pi/agent/intercom/broker.sock'
```

## z13 (same pattern)

`Host z13` in `~/.ssh/config` (`z13.local`, user `blueaz`). Same Desktop
broker; a third reverse Unix-socket forward. z13 sessions are untrusted
remote content, like Testbench and Mac. The path string matches Desktop
(`/home/blueaz/.pi/agent/intercom/broker.sock`) but is the **remote**
filesystem; do not confuse the two hosts.

```sh
ssh z13 'export PATH="$HOME/.local/bin:$PATH"; pi install npm:pi-intercom@0.13.0'
ssh z13 'mkdir -p ~/.pi/agent/intercom && chmod 700 ~/.pi/agent ~/.pi/agent/intercom'
```

```sh
install -m644 ~/.dotfiles/machines/desktop/pi-intercom/pi-intercom-*.service \
  ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pi-intercom-z13-forward.service
```

z13 sshd snippet (local sudo on z13):

```sh
scp ~/.dotfiles/machines/desktop/pi-intercom/z13-sshd-intercom.conf \
  z13:/tmp/90-pi-intercom.conf
ssh -t z13 'sudo install -m644 /tmp/90-pi-intercom.conf /etc/ssh/sshd_config.d/90-pi-intercom.conf && sudo sshd -t && sudo systemctl reload ssh'
```

Inspect:

```sh
systemctl --user status pi-intercom-z13-forward.service
ssh z13 'stat -c "%F %a" ~/.pi/agent/intercom/broker.sock'
```

Stop/disable the prototype with:

```sh
systemctl --user disable --now pi-intercom-testbench-forward.service
systemctl --user disable --now pi-intercom-mac-forward.service
systemctl --user disable --now pi-intercom-z13-forward.service
```
