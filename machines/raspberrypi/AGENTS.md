# Raspberry Pi Guidelines

## Machine Overview
- Host: `raspberrypi`.
- Hardware: Raspberry Pi 3 family; exact model is still uncertain. Confirm whether it is Raspberry Pi 3 Model B or 3 Model B+ from board silkscreen.
- OS: Raspberry Pi OS, Raspbian/Debian 13-era image, kernel observed as `6.12.75+rpt-rpi-v7` on 2026-05-20.
- Goal: headless access from the Z13 laptop over SSH, with no monitor/keyboard required.

## Stow Packages & Linking
- Packages: none currently. This is a device access and recovery note, not a dotfiles stow target yet.
- Outputs/config links: none currently.

## Machine-Specific Notes
- User account:
  - SSH login user created during recovery: `blueaz`.
  - Do not assume old Raspberry Pi defaults. Modern Raspberry Pi OS has no default `pi`/`raspberry` login.
- Networking:
  - LAN subnet: `192.168.8.0/24`, router `192.168.8.1`.
  - Ethernet IP observed: `192.168.8.147`.
  - Wi-Fi IP observed: `192.168.8.184`.
  - Wi-Fi SSID observed on Pi: `da4e9a`.
  - Laptop Wi-Fi was on `da4e9a_5G`; if this board is a Pi 3 Model B, remember it only supports 2.4 GHz Wi-Fi.
  - `.local` name resolution did not work from the laptop during recovery; use direct IPs unless Avahi/mDNS is confirmed.
- SSH:
  - `ssh.service` was enabled and running.
  - SSH banner observed from laptop: `OpenSSH_10.0p2 Raspbian-7+deb13u2`.
  - Working command after account setup:
    - `ssh blueaz@192.168.8.147`
    - `ssh blueaz@192.168.8.184`
  - The Z13 laptop had a local SSH client config issue:
    - `Bad owner or permissions on /etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf`
    - Workaround: `ssh -F /dev/null blueaz@192.168.8.147`
- SD card and recovery notes:
  - SD card used during recovery was `/dev/mmcblk0` on the Z13 laptop; laptop SSD is `/dev/nvme0n1` and must never be touched.
  - Original NOOBS install was wiped. NOOBS is gone.
  - First Raspberry Pi Imager attempt did not persist OS customization, leaving the Pi at first-boot user setup with no valid SSH login user.
  - SSH was enabled by creating the boot partition marker file `ssh`.
  - User creation was repaired by writing `userconf.txt` to the boot partition with a SHA-512 password hash for user `blueaz`.
  - If redoing this, use Raspberry Pi Imager and ensure `Edit Settings` is saved before writing:
    - hostname
    - username/password
    - Wi-Fi SSID/password and country `US`
    - SSH enabled
- Display:
  - HDMI had no output during recovery, likely EDID/driver fussiness on Pi 3.
  - Fallback `config.txt` settings that helped target HDMI-safe mode:
    - `hdmi_force_hotplug=1`
    - `hdmi_safe=1`
- Power:
  - Use official Raspberry Pi PSU. Do not suggest powering this Pi from laptop USB.

## Validation Notes
- Check reachability from the Z13:
  - `ping 192.168.8.147`
  - `ping 192.168.8.184`
- Check SSH:
  - `ssh -F /dev/null blueaz@192.168.8.147`
  - `ssh -F /dev/null blueaz@192.168.8.184`
- Check services on the Pi:
  - `sudo systemctl status ssh`
  - `ip -br addr`
  - `nmcli con show --active`
- Current state when this guide was created:
  - SSH connection had been closed by the user.
  - Pi still responded to ping on both `192.168.8.147` and `192.168.8.184`.
  - `raspberrypi.local` and `pi.local` did not resolve from the laptop.
