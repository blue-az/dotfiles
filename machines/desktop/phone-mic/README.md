# Phone microphone as a Desktop input

Streams the Galaxy S10e's (SM-G970F, Android 14, serial `RF8M40GB76F`) microphone
over USB with scrcpy and presents it as an ordinary input named **PhoneMic**
(source `phone_mic`), e.g. for voice input in pi. USB tethering does not carry
audio; this does.

| File | Installs to | Does |
|---|---|---|
| `phone-mic.conf` | `~/.config/pipewire/pipewire-pulse.conf.d/` | Creates the `phonemic` null sink and the `phone_mic` input from its monitor; routes scrcpy's stream into `phonemic` |
| `phone-mic-scrcpy.service` | `~/.config/systemd/user/` | Runs `scrcpy --no-video --no-control --audio-source=mic`, restarting with backoff (10 s up to 15 min) while the phone is unplugged |

## Prerequisites

- scrcpy 4.x at `~/.local/bin/scrcpy`. Fedora's repos do not carry it; the
  official build is used, checksum-verified against the release's
  `SHA256SUMS.txt`, unpacked to `~/.local/opt/scrcpy-v4.1/` and linked.
- USB debugging on, and this computer allowed on the phone ("Allow USB
  debugging"). The USB mode can stay on "No data transfer"; ADB works in any
  mode.

## Install

```sh
D=~/.dotfiles/machines/desktop/phone-mic
install -Dm644 $D/phone-mic.conf ~/.config/pipewire/pipewire-pulse.conf.d/phone-mic.conf
systemctl --user restart pipewire-pulse.service   # audio blips for a second
install -m644 $D/phone-mic-scrcpy.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now phone-mic-scrcpy.service
```

Use it by choosing PhoneMic as the input, or make it the default with
`pactl set-default-source phone_mic`.

## Notes

- Routing needs `stream.rules` (in `phone-mic.conf`). `PULSE_SINK` alone was not
  honoured, and `pulse.rules` match the client rather than the stream, so without
  the rule scrcpy's stream follows the default sink and plays the phone mic out
  of the speakers.
- `cycle-audio-source.sh` only ever selects the HDMI, built-in and EarPods sinks,
  so it never makes `phonemic` the default output.
- Mic capture may stop when the phone's screen locks; check that first if
  PhoneMic goes silent.
- Verified 2026-10-02: after a `pipewire-pulse` restart and a fresh service
  start, scrcpy's stream landed on `phonemic` without intervention and PhoneMic
  carried signal (3 s test, peak -24 dBFS; recording deleted).
- Remove: `systemctl --user disable --now phone-mic-scrcpy`, delete the two
  installed files, restart `pipewire-pulse`.
