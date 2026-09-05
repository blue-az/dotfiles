# Test Bench — Issues

## OPEN — No working WiFi. Wired ethernet only.

**The board has no onboard WiFi.** The MSI MPG Z390 **Gaming Plus** has none —
that is the *Gaming Edge AC* / *Pro Carbon AC* variants. A USB adapter was bought
to cover it and does not currently work.

### The adapter

| | |
|---|---|
| Chipset | **aicsemi AIC8800** family |
| USB ID | `a69c:5721` |
| Enumerates as | `bInterfaceClass 8` — **USB Mass Storage**, not a network device |
| Mainline kernel support | **none** |

It ships in driver-CD mode and must be **mode-switched** before it presents as a
network interface — `usb_modeswitch`, or the udev rules the driver packages
install. The documented pattern for this family is
`usb_modeswitch -K -v a69c -p 5722`.

### Driver status, measured 2026-09-04

Community DKMS drivers exist and are actively maintained:

- `goecho/aic8800_linux_drvier` (the typo in that repo name is upstream's)
- `susers/aic8800_linux_driver`
- `RicknotDev/aic8800d80`

**Tested on the desktop (Fedora 43, kernel 7.1.9): does not build.** The driver
declares vendor `0xA69C` so it does target this device, but kernel 7.x changed
the `cfg80211` API — every callback now takes `struct wireless_dev *` where the
driver passes `struct net_device *`. `add_station`, `del_station`,
`change_station`, `get_station`, `add_key`, `get_key`, `del_key`,
`cfg80211_new_sta` and `cfg80211_del_sta` all fail to compile. That is a port,
not a patch.

Upstream's most recent compatibility work is a **kernel-6.17** merge
(2026-08-17).

### Why it may still work *here*

**Debian ships a 6.x kernel**, which is inside the range this driver already
supports. The older distro is the advantage. Worth trying on this machine even
though it is dead on the desktop.

### Rules

1. **Try it only after the machine is online over ethernet.** Never make this
   adapter the only path to network — you would need the network to download the
   driver that provides the network.
2. **This is out-of-tree kernel-space code from an unvetted repository.**
   Acceptable on a bench. Think before putting it on a machine holding real work.
3. If it works, **record the kernel version it worked on** — it will break on a
   kernel bump until upstream catches up, and DKMS will rebuild it against a
   kernel it may not support.

### Resolution paths

- **Now:** wired ethernet.
- **Likely:** the driver builds on Debian's 6.x kernel. Untested.
- **Eventually:** upstream ports to 7.x. The repo tracked 6.17 within weeks of
  release, so a 7.x port is plausible but unscheduled.
- **Alternative:** a dongle with mainline support — Realtek `rtl8812au`/`88x2bu`
  class parts and most Mediatek `mt7921u` devices work without out-of-tree code.
  Cheaper than fighting this one if WiFi ever becomes load-bearing here.

---

## OPEN — Machine not yet recorded from itself

The parts list records the board and RAM from a **2019 build spec**, not from
this machine. Close it with:

```
sudo dmidecode -t baseboard -t memory | head -40
sudo smartctl -a /dev/nvme0n1 | grep -iE "model|power_on_hours|percentage_used|critical"
```

The SMART read matters: the PM981a is an **OEM drive with no consumer
warranty**, so Power On Hours and Percentage Used are worth knowing on day one
rather than day ninety.

Also confirm RAM reports **16 GB dual-channel**. Single-channel means the sticks
are in the wrong slots — A2/B2, the 2nd and 4th from the CPU.

---

## RESOLVED 2026-09-04 — "the PSU is dead"

It was not. The power switch had never been connected to `JFP1`, so nothing was
pulling `PS_ON#` low. A silent, dark, unresponsive ATX PSU in standby is correct
behaviour. Full diagnostic trail and the healthy-standby signature are in
[`BUILD_HANDOFF.md`](BUILD_HANDOFF.md).

## RESOLVED 2026-09-04 — CPU↔DRAM debug-LED loop

Dirty DIMM contacts on the 2019-vintage kit. Swapping sticks did not fix it;
cleaning the contacts with isopropyl alcohol did.

---

## UPDATE 2026-09-04 evening — Debian attempt status before Ubuntu retry

Operator is likely going to try Ubuntu next. Preserve these details because the
AIC8800 WiFi result was useful even though the NVIDIA/Sway stack became unstable.

### What worked on Debian 12

Baseline machine state that was good before proprietary NVIDIA driver work:

- Debian 12 / bookworm, kernel `6.1.0-52-amd64`.
- Hostname: `testbench`; user: `ef-tb`.
- Sway came up from LightDM and showed the Debian wallpaper.
- Dotfiles cloned at `~/.dotfiles`, with testbench files copied from desktop.
- Repos cloned at `~/Python`, `~/operator-control-plane`, `~/.dotfiles`.
- GitHub CLI installed locally at `~/.local/bin/gh` and authenticated as
  `blue-az`.
- `fastfetch` installed locally at `~/.local/bin/fastfetch`.
- SSH to desktop works with alias `desktop`, user `blueaz@desktop.local`.
- RTX 2080 was visible and drove display with nouveau; Waybar GPU fallback was
  patched to show `RTX-2080-Rev.-A-D: nouveau` when `nvidia-smi` is absent.

### AIC8800 USB WiFi — important details

This was the success. The cheap AICSemi dongle does work on Debian 12 with the
community DKMS driver.

Hardware/USB states:

- Initial fake driver-CD/storage mode: `a69c:5721 aicsemi Aic MSC`.
- Shows as a tiny USB disk: `sda usb AIC flash 3.9M`.
- Working WiFi mode after eject/udev/driver: `368b:8d81 AICSemi AIC 8800D80`.
- Network interface: `wlx8c773b23c4e9`.
- MAC: `<adapter MAC redacted>`.
- Connected SSID: `da4e9a_5G`.
- IP when tested: `192.168.8.119/24`.
- NetworkManager reported full IPv4/IPv6 connectivity.
- Link was on 5 GHz, channel 149 / 5745 MHz, 100% signal, displayed rate
  270 Mbit/s.
- With ethernet unplugged, observed throughput was about **250 Mbps**, roughly
  40 Mbps slower than ethernet in the same position.

Driver/repo:

- Repo used: `RicknotDev/aic8800d80`.
- Local clone on Debian attempt: `~/src/aic8800d80`.
- Commit observed: `99822dc`.
- Kernel modules loaded: `aic_load_fw`, `aic8800_fdrv`.
- It builds on Debian kernel `6.1.0-52-amd64` when built from the top-level
  `drivers/aic8800` directory. Building only `aic8800_fdrv` produced undefined
  symbol errors because `aic_load_fw` exports required symbols.
- Setup helper created on the Debian install: `~/setup-aic8800-wifi.sh`.
- Safe NetworkManager tweaks applied while it worked:
  - WiFi powersave disabled for connection `da4e9a_5G`.
  - Band pinned to 5 GHz (`802-11-wireless.band a`).
  - BSSID pinned to `<BSSID redacted — a router MAC is geolocatable via wardriving databases; keep it out of a public repo>`.
  - Autoconnect priority raised.

Caveat: still out-of-tree community kernel code. Good enough for a bench; keep
wired ethernet as the recovery path. Fedora/kernel 7.x still did not build due
to cfg80211 API changes, so this is not portable to the desktop yet.

### NVIDIA/Sway failure

Attempted to install Debian proprietary NVIDIA packages for CUDA/`nvidia-smi`:

- Enabled `contrib non-free non-free-firmware` in apt sources.
- Installed Debian `nvidia-driver`/`nvidia-smi` stack version `535.309.01`.
- After reboot, `nvidia-smi` worked and showed RTX 2080, but Sway login broke.
- Plain Sway fails because Debian Sway 1.7 refuses proprietary NVIDIA unless
  run with `--unsupported-gpu`.
- A custom `Sway NVIDIA` session using `/usr/local/bin/sway-nvidia` and
  `sway --unsupported-gpu` was attempted; it also failed / returned to login.
- User ended up back in XFCE / safe-mode style sessions.

Revert attempt:

- Helper scripts created: `~/revert-to-nouveau-sway.sh` and then safer
  `~/revert-to-nouveau-sway-safe.sh`.
- The first script stopped LightDM first and got interrupted, leaving the system
  half-changed.
- The safe script later purged NVIDIA packages, removed the custom Sway NVIDIA
  session, reinstalled nouveau/Mesa/Sway/LightDM, and rebuilt initramfs.
- Post-safe-script status observed from agent:
  - NVIDIA packages no longer listed as installed.
  - `/usr/share/wayland-sessions` only had plain `sway.desktop`.
  - `nouveau` module was loaded again.
  - AIC8800 WiFi still worked.
  - LightDM was inactive in the current safe-mode context.
- Despite this, operator reported Sway still had problems. Do not spend more
  time rescuing this Debian graphical stack unless needed; Ubuntu retry is a
  reasonable next step.

### ⚠️ KERNEL CEILING — this decides which Ubuntu to install

The AIC8800 driver fails to build from **kernel 7.x** onward. Kernel 7.x changed
the `cfg80211` API so every callback takes `struct wireless_dev *` where the
driver passes `struct net_device *`; `add_station`, `del_station`,
`get_station`, `add_key`, `get_key`, `del_key`, `cfg80211_new_sta` and
`cfg80211_del_sta` all fail. Upstream's newest compatibility work targets 6.17.

| release | kernel | AIC8800 |
|---|---|---|
| Ubuntu 26.04 LTS | **7.0** | ❌ breaks — same wall as Fedora 43 |
| Ubuntu 25.10 | 6.17 | ⚠️ upstream's newest target, at the edge |
| **Ubuntu 24.04 LTS — GA stack** | **6.8** | ✅ safely inside range |
| Ubuntu 24.04 LTS — **HWE stack** | **7.0** | ❌ HWE has rolled to 7.0 |
| Debian 12 (known-good) | 6.1 | ✅ proven working |

**Install Ubuntu 24.04 LTS and stay on the GA kernel.** The trap is that 24.04's
hardware-enablement stack has since moved to 7.0, so accepting HWE lands you
back on a kernel that cannot build this driver. Do not take an HWE kernel
upgrade until upstream ports to 7.x.

This is also a standing hazard, not a one-time choice: **an unattended kernel
upgrade will silently break WiFi on this machine.** DKMS will attempt a rebuild
against a kernel the driver does not support and fail. Keep ethernet reachable.

### Recommendation for Ubuntu retry

1. Install Ubuntu normally with wired ethernet available.
2. Before NVIDIA/CUDA, first confirm display manager + Sway/desktop baseline.
3. Re-try AIC8800 using `RicknotDev/aic8800d80`; kernel compatibility may differ
   from Debian 6.1, but the Debian result proves the hardware is viable.
4. For NVIDIA, prefer Ubuntu's supported-driver path (`ubuntu-drivers`) rather
   than manually mixing display-stack assumptions.
5. Keep a note of whether Ubuntu kernel is too new for AIC8800; if it fails,
   Debian 6.1 remains the known-good WiFi kernel/driver combo.

---

## 2026-09-04 late — decision: stop chasing Sway; keep stable headless/XFCE bench

Latest operator direction: this machine is primarily a GPU/test bench and can be
run headless or from XFCE. Sway is no longer a requirement for this host. The
working target is now:

- Ethernet first.
- SSH reachable from desktop.
- XFCE/LightDM acceptable as the local GUI.
- Sway remains installed only for manual experiments; do not block CUDA/GPU work
  on Sway.

Changes applied on the Debian install after reading this handoff:

- Added the desktop public key to `~/.ssh/authorized_keys` so desktop can SSH to
  the bench as `ef-tb@testbench.local` / `ef-tb@192.168.8.171` once name
  resolution cooperates.
- Confirmed `ssh` service is active.
- Disabled TTY1 Sway autostart in `~/.dotfiles/bash/.bash_profile`; no more
  automatic `exec sway` on console login.
- Left a minimal recovery Sway config at `~/.config/sway/config`, but the
  dotfiles Sway symlink is disabled. Sway is optional/manual now.
- Kept ethernet connected and primary.

### WiFi wake/resume suspicion

Operator noted the AIC8800 WiFi may have contributed to the machine not waking
up / appearing stuck. For stability, WiFi was disabled and autoconnect turned
off while ethernet is available:

```
nmcli radio wifi off
nmcli connection modify da4e9a_5G connection.autoconnect no
```

Observed stable network state after this:

```
eno1    ethernet  connected  Wired connection 1
lo      loopback  connected
```

Do not treat WiFi as a boot/resume dependency. It is a successful experiment and
useful fallback, not the primary network path. Known-good details remain:

- AIC8800 fake storage mode: `a69c:5721 aicsemi Aic MSC`.
- Working WiFi mode: `368b:8d81 AICSemi AIC 8800D80`.
- Interface: `wlx8c773b23c4e9`.
- Driver repo: `RicknotDev/aic8800d80`, commit observed `99822dc`.
- Modules: `aic_load_fw`, `aic8800_fdrv`.
- Debian known-good kernel: `6.1.0-52-amd64`.
- Performance when tested: about 250 Mbps on `da4e9a_5G`.

### Revised plan

Before reinstalling Ubuntu, consider staying on this Debian install if XFCE +
SSH + ethernet are stable. The prior Debian CUDA test succeeded: `nvidia-smi`
worked with NVIDIA `535.309.01`; Sway was the broken layer, not CUDA. If the
bench's job is GPU/CUDA work rather than daily desktop use, reinstalling only to
fix Sway is probably wasted motion.

If retrying NVIDIA on Debian, do it with Sway out of scope:

1. Keep ethernet connected.
2. Keep WiFi disabled unless explicitly testing it.
3. Install NVIDIA driver/CUDA.
4. Verify `nvidia-smi` over SSH or XFCE.
5. Do not attempt Sway until after GPU work is otherwise complete, if ever.

---

## 2026-09-04 late — CUDA/XFCE path confirmed working

Final decision for this Debian install: **XFCE/headless is the supported local
workflow; Sway is out of scope.** After killing the stuck NVIDIA debconf
`whiptail` dialog and completing package configuration, the CUDA stack installed
and survived reboot.

Verified on the bench after reboot in XFCE:

```
DESKTOP=XFCE SESSION=xfce DISPLAY=:0.0 WAYLAND=
Kernel driver in use: nvidia
nvidia-smi: Driver Version 535.309.01, CUDA Version 12.2 reported by driver
nvcc: CUDA compilation tools release 11.8, V11.8.89
CUDA smoke test: cuda_devices=1 sync=no error
Network: eno1 ethernet connected; WiFi disabled/not primary
```

GPU reported by `nvidia-smi`:

```
NVIDIA GeForce RTX 2080
Bus-Id 00000000:01:00.0
Display Active: On
Memory: 8192 MiB
Idle temp around 31 C, idle power 4-5 W
```

Installed Debian packages include:

- `nvidia-driver` `535.309.01-0+deb12u1`
- `nvidia-smi` `535.309.01-0+deb12u1`
- `nvidia-cuda-toolkit` `11.8.89~11.8.0-5~deb12u1`
- `nvidia-settings`
- `nvtop`

Important operational note: during install, Debian's `xserver-xorg-video-nvidia`
postinst displays a `whiptail` warning that nouveau is currently loaded. In this
session the OK button could not be activated. The workaround was to kill the
`whiptail` PID, then finish configuration:

```
sudo kill <whiptail-pid>
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sudo update-initramfs -u
sudo reboot
```

This did not indicate driver failure. It was an interactive packaging dialog
problem. After reboot, NVIDIA/CUDA worked.

Current known-good role for this machine:

- Debian 12 bench host.
- XFCE/LightDM for local GUI.
- SSH + ethernet for normal operation.
- NVIDIA/CUDA working on RTX 2080.
- AIC8800 WiFi is a successful experiment/fallback but disabled for stability
  because it may have contributed to wake/resume problems.
- Do **not** spend more time making Sway work unless there is a separate reason;
  it is not required for the bench mission.

---

## 2026-09-05 — stable-state addendum: suspend, WiFi retest, backups

Additional validation after the headless/CUDA baseline:

### Suspend / wake

- `susp` helper exists on the bench and runs `systemctl suspend`.
- Suspend/resume works reliably when waking with the **physical power button**.
- Keyboard wake was investigated briefly. Logitech receiver wake was already
  enabled and USB root hubs can be toggled, but keyboard wake is not worth
  chasing for this bench. Treat power-button wake as the supported path.

### WiFi retest after CUDA/NVIDIA stable state

The AIC8800 dongle was plugged back in and retested after the stable XFCE/CUDA
state was reached.

Observed state:

- Ethernet remained primary: `eno1`, metric 100.
- WiFi connected successfully as fallback: `wlx8c773b23c4e9`, SSID `da4e9a_5G`,
  metric 600.
- Adapter again appeared in working mode as `368b:8d81 AICSemi AIC 8800D80`.
- AIC modules loaded: `aic_load_fw`, `aic8800_fdrv`.
- USB wake for the AIC adapter was disabled.
- Suspend/wake behaved the same with WiFi plugged in: wake by power button was
  fine. No new failure reproduced in this short test.

Policy remains: ethernet is primary; WiFi is a useful fallback/experiment, not a
boot/resume dependency.

### Backups

A config/state backup was made to the desktop earlier:

- `desktop:/tmp/testbench-backup-20260904-232044.tar.gz`

A USB hard drive was then mounted at `/mnt/qwen-staging` and cleaned. Old
`Qwen3.8-Flash-Next-NVFP4` staging data (~126G) was deleted. The USB now holds
only the testbench backup directory plus `lost+found`.

Current USB backup:

- `/mnt/qwen-staging/testbench-backups/testbench-config-backup-20260905-000136.tar.gz`
- Size: about 19M
- USB free space after cleanup: about 139G free of 146G

Backup contents include system/package state, apt sources, LightDM/modprobe/udev
config, XFCE/Sway/Waybar config snapshots, setup/revert/verify scripts, and
install logs. It intentionally avoids SSH private keys and NetworkManager WiFi
secrets.

### Current known-good summary

- Debian 12 / bookworm on `testbench`.
- XFCE/LightDM is the local GUI.
- Mostly-headless operation over SSH is confirmed from desktop.
- Ethernet is the supported primary network.
- NVIDIA driver 535.309.01 and CUDA toolkit 11.8 are installed and verified.
- RTX 2080 CUDA smoke test passed: `cuda_devices=1 sync=no error`.
- AIC8800 WiFi works on Debian 6.1 as fallback.
- Sway should not be pursued on this host unless a future need appears.

---

## NOTE — do not record network identifiers here. This repo is public.

`blue-az/dotfiles` is a **public** repository. Two classes of identifier must
never land in it:

- **BSSID / router MAC.** Wardriving databases (WiGLE and similar) index
  BSSID → physical coordinates. Publishing one is effectively publishing the
  street address of the network. One was redacted from these files on
  2026-09-05 before it was ever pushed.
- **Client MAC addresses.** Persistent hardware identifiers.

Internal IPs (`192.168.x.x`) and hostnames are fine — they mean nothing outside
the LAN.

**Already public and not fixable by editing HEAD:** the SSID `da4e9a_5G` is in
`machines/raspberrypi/AGENTS.md` and `machines/z13-amd/bash_aliases` on
`origin/main` from earlier work. Lower severity than a BSSID — an SSID is
broadcast continuously and is far less precisely locatable — but worth knowing
it is out there. Removing it would require history rewriting across pushed
commits.

If a WiFi detail is genuinely needed for reproduction, keep it in a local
untracked note and reference it here by description, not by value.
