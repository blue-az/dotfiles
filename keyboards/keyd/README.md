# keyd — scancode-level key remapping

`default.conf` here is the tracked copy of `/etc/keyd/default.conf`. It is **not**
a stow package: keyd is a system daemon and its config lives under `/etc`, so the
file is installed explicitly rather than symlinked from `$HOME`.

## Current mapping

| Press | Emits |
| --- | --- |
| `;` | Right Ctrl (the real Right Ctrl is untouched) |
| `Shift+;` | `:` — unmoved, where vim expects it |
| `AltGr+;` | `;` — the displaced semicolon, on Right Alt |

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
leaked `VKEY_BACK`.

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
