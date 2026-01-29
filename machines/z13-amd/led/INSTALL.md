# Z13 LED DIY Install (Fedora)

These files are adapted from the community z13 LED script and use a group-scoped udev rule (no world-writable devices).

## 1) Create or reuse a group
Use `plugdev` (recommended) or a dedicated group.

```bash
sudo groupadd -f plugdev
sudo usermod -aG plugdev $USER
```
Log out/in to refresh group membership.

## 2) Install the script
```bash
install -m 0755 ~/.dotfiles/machines/z13-amd/led/z13-led ~/.local/bin/z13-led
```

## 3) Install udev rule and service
```bash
sudo install -m 0644 ~/.dotfiles/machines/z13-amd/led/99-asus-rgb.rules /etc/udev/rules.d/99-asus-rgb.rules
sudo install -m 0644 ~/.dotfiles/machines/z13-amd/led/z13-restore.service /etc/systemd/system/z13-restore.service
```

## 4) Reload and test
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl daemon-reload
sudo systemctl start z13-restore.service
```

## 5) Manual commands
```bash
# Lightbar on/off
~/.local/bin/z13-led --on
~/.local/bin/z13-led --off

# Lightbar color (R G B)
~/.local/bin/z13-led -c 0 255 0

# Keyboard color (R G B)
~/.local/bin/z13-led -k -c 0 255 0
```

## Notes
- If the lightbar does not respond, inspect `/sys/class/hidraw/hidraw*/device/uevent` for the expected HID_PHYS signatures.
- If you change the group name, edit `99-asus-rgb.rules` accordingly.
