# PinePhone Guidelines

## Machine Overview
- Host: PINE64 PinePhone Convergence Edition, 3 GB RAM / 32 GB eMMC.
- OS: postmarketOS `v25.12` Phosh booted from microSD.
- Goal: recover access to a locked PinePhone by booting a known-good SD image, then configure networking/SSH for maintenance.

## Stow Packages & Linking
- Packages: none currently. This is a device recovery note, not a dotfiles stow target yet.
- Outputs/config links: none currently.

## Machine-Specific Notes
- Hardware:
  - This is a regular PinePhone, not a PinePhone Pro. Use images for `pine64-pinephone`; do not use PinePhone Pro images.
  - PinePhone boots the upper microSD slot before internal eMMC, which bypasses the locked internal OS.
- Image used on 2026-05-20:
  - postmarketOS `v25.12`, Phosh, build `20260520-0353`
  - URL: `https://images.postmarketos.org/bpo/v25.12/pine64-pinephone/phosh/20260520-0353/20260520-0353-postmarketOS-v25.12-phosh-25-pine64-pinephone.img.xz`
  - SHA-256: `ff7ef6e71a3d1f65fc1f44f06ee34d21fb8c838854610145f14d3678a08c59f7`
  - Downloaded to `/tmp/20260520-0353-postmarketOS-v25.12-phosh-25-pine64-pinephone.img.xz` and verified with `sha256sum` plus `xz -t`.
- Flashing:
  - Flash target was removable microSD `/dev/mmcblk0`, previously labeled `CB Backup`.
  - Never write to `/dev/nvme0n1`; that is the Z13 laptop SSD.
  - Helper script created at repo root: `flash-pinephone-sd.sh`.
  - The helper verifies the image hash, displays `/dev/mmcblk0`, requires typing `FLASH`, then writes with `xzcat | sudo dd of=/dev/mmcblk0 bs=4M status=progress conv=fsync`.
- Default postmarketOS login on this image:
  - user: `user`
  - password/PIN: `147147`
- USB networking from the Z13 laptop:
  - Enumerates as `PINE64 PinePhone`, serial `postmarketOS`, USB ID `18d1:d001`.
  - Presents CDC NCM network interface `enp198s0f4u1` on the laptop.
  - Stable link gives laptop `172.16.42.2/24` and phone `172.16.42.1`; `ping 172.16.42.1` worked.
  - USB cable/connection was flaky and repeatedly disconnected/re-enumerated.
  - If `enp198s0f4u1` only has IPv6 link-local or NetworkManager is stuck getting IP configuration, reseat or change cable/port.

## Validation Notes
- Confirm boot from SD by unlocking with default PIN `147147`.
- Confirm USB enumeration on the laptop:
  - `lsusb` should show `18d1:d001` and `PINE64 PinePhone`.
  - `ip -br addr show enp198s0f4u1` should show `172.16.42.2/24` when USB networking is stable.
  - `ping 172.16.42.1` should reach the phone.
- Stopping point from recovery session:
  - Phone booted postmarketOS from SD and unlocked with `147147`.
  - USB networking worked intermittently.
  - SSH to `172.16.42.1:22` returned connection refused, so `sshd` was not running.
  - Suggested on-phone commands were `sudo rc-service sshd start` and `sudo rc-update add sshd default`, but they did not work from the phone console before stopping.
