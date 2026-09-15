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

Install the matching Pi and intercom package on Testbench (with the user's
Node 22 on `PATH`):

```sh
ssh testbench 'export PATH="$HOME/.local/bin:$PATH"; pi install npm:pi-intercom'
```

Create the remote socket directory once:

```sh
ssh testbench 'mkdir -p ~/.pi/agent/intercom && chmod 700 ~/.pi/agent ~/.pi/agent/intercom'
```

Install and start the Desktop-side service:

```sh
mkdir -p ~/.config/systemd/user
install -m644 ~/.dotfiles/machines/desktop/pi-intercom/pi-intercom-testbench-forward.service \
  ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pi-intercom-testbench-forward.service
```

Inspect it with:

```sh
systemctl --user status pi-intercom-testbench-forward.service
ssh testbench 'stat -c "%F %a" ~/.pi/agent/intercom/broker.sock'
```

The current package still auto-spawns a broker if the forwarded socket is
absent. Do not start Testbench Pi sessions while disconnected until an explicit
no-auto-spawn mode is implemented and tested; otherwise a local broker could
split the session roster.

Stop/disable the prototype with:

```sh
systemctl --user disable --now pi-intercom-testbench-forward.service
```
