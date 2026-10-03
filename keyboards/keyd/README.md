# keyd — scancode-level key remapping

`default.conf` here is the tracked copy of `/etc/keyd/default.conf`. It is **not**
a stow package: keyd is a system daemon and its config lives under `/etc`, so the
file is installed explicitly rather than symlinked from `$HOME`.

## Current mapping

| Press | Emits |
| --- | --- |
| `;` | Right Ctrl (the real Right Ctrl is untouched) |
| `Shift+;` | `:` — unmoved, where vim expects it |
| `Left Alt+;` | Backspace |
| `AltGr+;` | `;` — the displaced semicolon, on Right Alt |

## Foot pedal (`footpedal.conf`)

`footpedal.conf` is the tracked copy of `/etc/keyd/footpedal.conf`. Its `[ids]`
names the PCsensor FootSwitch (`1a86:e026`), which is more specific than
`default.conf`'s `*`, so keyd uses it for the pedal only. The pedal's firmware
sends Escape; keyd turns that into **F13**, and Sway (`machine.conf.desktop`,
`bindcode 191`) runs `sway/.local/bin/pedal-voice`, which types `/voice` + Enter
to start rpiv-voice dictation in the focused pi session.

Two things that did not work:

- A Sway `bindsym --input-device=...FootSwitch_Keyboard Escape` never fires:
  keyd grabs the pedal and re-emits its keys from `keyd_virtual_keyboard`.
- A keyd `macro(/voice enter)` works, but a quick double press runs two macros at
  once and types `/vovoice`. keyd cannot ignore the second press, so the typing
  moved to `pedal-voice`, which drops presses within 1.5 s.

keyd also grabs the pedal's mouse and joystick-style interfaces (it logs a
"trackpad" warning for one); nothing uses them.

Install: `sudo install -m644 footpedal.conf /etc/keyd/footpedal.conf && sudo keyd reload`

## Planned: keyboard triggers for `/voice` (not implemented)

Ideas for firing `pedal-voice` without the pedal, e.g. on the z13 where there is
none. Both would emit the same F13 the pedal does, so the Sway side stays one
`bindcode 191`.

**A Windows key → F13.** Super is Sway's `$mod`, so the key can't simply be
remapped away:

- If the keyboard has a second Win key (`rightmeta`), map that one outright:
  `rightmeta = f13`. Check with `keyd monitor`; the z13's GZ302EA keyboard may
  only have the left one.
- Otherwise overload the only one: `leftmeta = overload(meta, f13)`. Held or
  chorded it is still Super; tapped alone it sends F13. Risk: an aborted Super
  shortcut (press Super, change your mind, release) now fires dictation.

**Hold Space → F13.** `space = timeout(space, <ms>, f13)`: tap or roll into
the next key and it types a space; hold past `<ms>` alone and it sends F13.
Tradeoffs:

- Space is sent on release rather than press, a small but noticeable lag.
- Holding Space to auto-repeat spaces stops working, and so does anything else
  that expects a held Space (video players, games).
- The threshold needs tuning: too short misfires during slow typing, too long
  feels sluggish. Start around 400 ms.

**Before either one ships:**

- `pedal-voice` types `/voice` + Enter into *whatever is focused*. A misfire from
  a keyboard key is far more likely than a pedal misfire, and in a plain shell it
  runs `/voice` as a command. Consider having `pedal-voice` check that the focused
  window is a pi session (`swaymsg -t get_tree`) before typing.
- `default.conf` uses `[ids] *` and is installed on every machine. A laptop-only
  trigger needs its own file naming the GZ302EA keyboard's id, the same way
  `footpedal.conf` names the pedal.
- On the z13: the `bindcode 191` binding lives in `machine.conf.desktop`, so it
  would need adding to `machine.conf.z13-amd`. `pedal-voice` isn't linked into
  `~/.local/bin`, and `wtype` isn't installed (`sudo dnf install wtype`). The
  pedal docs also point rpiv-voice at the PhoneMic input, a desktop-only source,
  so the z13 would use its built-in mic instead.

## Why keyd instead of xkb

The `;` → BackSpace remap originally lived in `xkb/.config/xkb/symbols/custom` as
`semicolon_backspace`. It worked in every GTK/terminal app and broke in Chromium.

Chromium derives a key's legacy `keyCode` (Windows VKEY) by re-resolving that key's
keysym **with no modifiers applied**. With `BackSpace` on level 1 of `<AC10>`, every
press of that key — shifted or not — arrived tagged `VKEY_BACK` (8):

```
keydown  key=":"  code=Semicolon  keyCode=8
```

Blink's contenteditable handler dispatches on `keyCode`, not `key`, so `Shift+;`
deleted a character instead of inserting `:` — visible in LinkedIn's composer and in
any Electron app (VS Code, Slack, Discord, Signal). No amount of xkb tuning fixes
this: any key carrying a non-printable keysym on level 1 leaks that VKEY to Chromium
at every level.

keyd sits *below* xkb, on evdev scancodes. Physical `;` emits `KEY_RIGHTCTRL`;
`Shift+;` emits a genuine `shift + KEY_SEMICOLON`, which the (now stock US) keymap
resolves normally and Chromium tags `VKEY_OEM_1`. Side benefit: the remap now also
applies to the i3/X11 session and the TTY, which the Sway-only `xkb_file` never did.

The destination key later changed from BackSpace to Right Ctrl, but the reason for
staying below xkb did not: Right Ctrl is equally non-printable, so putting it on
level 1 of `<AC10>` would leak `VKEY_CONTROL` to Chromium the same way BackSpace
leaked `VKEY_BACK`. The Left Alt+; shortcut is also defined in keyd's `[alt]` layer, where it emits
a real Backspace event without changing the base `;` mapping.

## Install

keyd is not in the Fedora repos (the only copr, `meeuw/keyd`, builds for F44 only),
so it is a source build:

```sh
git clone --depth 1 https://github.com/rvaiya/keyd
cd keyd && make && sudo make install
sudo install -m644 ~/.dotfiles/keyboards/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

Installs to `/usr/local`. Upgrades are manual — re-run the clone and `make install`.
Since this is a root daemon outside dnf, it gets no security updates automatically.

## Fedora release upgrades

A `dnf system-upgrade` does not touch `/usr/local`, so the binary, the unit at
`/usr/local/lib/systemd/system/keyd.service`, the `keyd` group, and
`/etc/keyd/default.conf` all survive. keyd links only libc and needs nothing newer
than `GLIBC_2.34`, so a binary built on one release keeps running on the next
without a rebuild.

**If you ever switch to the copr package, uninstall the source build first.**
`/usr/local/lib/systemd/system` takes precedence over `/usr/lib/systemd/system`, so
a leftover source-built unit silently overrides the RPM's:

```sh
cd /path/to/keyd-source && sudo make uninstall   # BEFORE dnf install keyd
```

Note that keyd has no Fedora dist-git project, so it will not appear in the official
repos on any release — `meeuw/keyd` (F44+) is the only packaged route.

## Applying config changes

```sh
sudo install -m644 ~/.dotfiles/keyboards/keyd/default.conf /etc/keyd/default.conf
sudo keyd reload
```

Validate before installing with `keyd check keyboards/keyd/default.conf`.

## Panic

keyd grabs the keyboard, so a bad config can lock you out. Hold
**backspace + escape + enter** together to terminate the daemon. Use the real
Backspace key — `;` is Right Ctrl under this config and will not work in the chord.

`keyd monitor` prints live key events (useful for confirming what the daemon emits);
`keyd -h` lists the rest.
