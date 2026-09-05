# HANDOFF — System 2 / test bench build

**Opened 2026-09-04. UPDATED same day: Debian installed, RTX 2080 in, machine
is up.** This file is the build log and the gotcha record. The parts list and
compatibility chain live in [`../parts/README.md`](../parts/README.md); the
machine's standing guidance is in [`AGENTS.md`](AGENTS.md) and open problems in
[`ISSUES.md`](ISSUES.md).

## Why this machine exists

Two jobs, in order:

1. **Validate the RM1000x** — the warranty replacement for the HX750i that
   failed 2026-07-27. Doing it here rather than in System 1 means a fault is
   isolated to a machine nothing depends on.
2. **Be the bench for 3090 configuration work.** System 1 is mid-benchmark-
   program and should not be disturbed. Having a second machine means single-
   GPU and dual-GPU configurations can be held simultaneously instead of
   toggling a systemd override back and forth on the only box.

Sequence changed 2026-09-03: the RM1000x goes **here**, not into System 1. The
Rosewill 850W stays in System 1 indefinitely.

## Validated so far

| item | status |
|---|---|
| Corsair RM1000x 1000W | ✅ **alive and switching** — see the standby readings below |
| MSI MPG Z390 Gaming Plus | ✅ POSTs |
| Intel i3-9100F | ✅ passed CPU phase |
| Corsair Vengeance LPX 2x8GB DDR4-3200 | ✅ **after cleaning contacts with IPA** — see below |
| Samsung PM981a 512GB NVMe | ✅ **Debian installed** |
| 65W cooler, LGA115x | ✅ mounted, fits |
| W01 open-air frame + 2-pin momentary switch | ✅ in use |
| ASUS RTX 2080 | ✅ **installed 2026-09-04** |
| Network | wired ethernet only — see the WiFi section |

## Gotchas discovered during this build — read before diagnosing anything

### 1. A PSU sitting silent is not a dead PSU

Hours were spent on this. An ATX PSU plugged into mains with the rocker on
supplies **only +5VSB** and nothing else. No fan, no hum, no lights. The main
rails stay off until `PS_ON#` is pulled to ground. That is correct behaviour.
The RM series also has **zero-RPM fan mode**, so fan spin proves nothing even
under the paperclip test.

**The actual cause of "the PSU is dead" here was that the power switch had
never been connected to `JFP1`.** Nothing was telling it to turn on.

### 2. Healthy 24-pin standby signature

Meter on DC volts, black probe on the PSU housing, 24-pin disconnected from the
board, rocker on:

- **Exactly two pins read ~5 V** — `+5VSB` (pin 9) and `PS_ON#` (pin 16, sitting
  pulled high waiting to be pulled down).
- **All other 22 pins read 0 V.** Every main rail is off in standby.
- **The EPS 8-pin reads 0 V on all pins.** It carries +12 V, which is off in
  standby. This is normal and is *not* evidence of a fault.

If you see that picture, the PSU is fine. Stop testing it.

### 3. The continuity beep test gives false grounds

Probing for ground with a beeper finds **bleeder paths**, not just grounds. With
the PSU off, the 12 V / 5 V / 3.3 V outputs read a low-resistance path to ground
through output caps and bleeder resistors — enough to trip a beeper, which
usually fires below ~50 Ω. Both 5 V pins appeared to have "grounds on both
sides", which made the standard `PS_ON#`-identification rule useless.

**Use actual resistance, not the beep.** A true ground is 0–1 Ω; a discharged
rail through a bleeder is tens to hundreds of ohms.

### 4. No lights in standby is normal on this board

MSI's EZ Debug LEDs illuminate during a **POST attempt**, not while sitting in
standby. A dark board with the rocker on means nothing.

### 5. A CPU↔DRAM LED loop was dirty DIMM contacts

The board cycled between the CPU and DRAM debug LEDs. Swapping to the other
stick did not fix it. **Cleaning the contacts with isopropyl alcohol did.**
Before suspecting a bad stick, bad slot, or bad memory controller, clean the
contacts — these are stored parts from a 2019 build.

Also relevant while diagnosing that loop: first boot with fresh RAM and a
cleared CMOS genuinely retrains several times before succeeding. **Give it
60–90 seconds** before intervening.

### 6. This board halts with no CPU fan

MSI refuses to proceed when it reads 0 RPM on `CPU_FAN`. Testing with the cooler
unmounted produces a boot loop that looks like a CPU fault and is not one.
(Also: don't run it uncooled anyway.)

### 7. The i3-9100F has no integrated graphics

**A completely black screen with no card installed is a successful POST, not a
failure.** Nothing will appear on the board's video ports ever — they are dead
on an F-series chip. The RTX 2080 must be in before any display test means
anything.

## Next steps

1. ~~Finish Debian install~~ **done 2026-09-04**, over wired ethernet.
2. ~~Install the ASUS RTX 2080~~ **done 2026-09-04.** On an open frame the card
   has nothing to brace against — confirm it is still supported, it is ~300 mm
   and heavy.
3. **Verify in BIOS/OS:** CPU identified as i3-9100F, RAM **16 GB dual-channel**
   (if it reports single-channel, the sticks are in the wrong slots — A2/B2, the
   2nd and 4th from the CPU), NVMe present.
4. **Record the machine against the parts list:**
   ```
   sudo dmidecode -t baseboard -t memory | head -40
   sudo smartctl -a /dev/nvme0n1 | grep -iE "model|power_on_hours|percentage_used|critical"
   ```
   The parts file currently records the board and RAM from a *build spec*, not
   from the machine. The SMART read matters — the PM981a is OEM with no
   consumer warranty, so its hours and wear are worth knowing on day one.
5. **Then**: 2080 out, 3090 in, and begin GPU configuration work.

## WiFi — do not count on it

A USB adapter was bought because the Gaming Plus has **no onboard WiFi**. It is
an **aicsemi AIC8800** (`a69c:5721`), and it enumerates as USB **Mass Storage**
until mode-switched (`usb_modeswitch`, or the udev rules the driver packages
ship).

**It has no mainline kernel support.** Community DKMS drivers exist —
`goecho/aic8800_linux_drvier`, `susers/aic8800_linux_driver`,
`RicknotDev/aic8800d80`.

**Tested on System 1 (Fedora 43, kernel 7.1.9) on 2026-09-04: it does not
build.** Kernel 7.x changed the `cfg80211` API so every callback takes
`struct wireless_dev *` where the driver passes `struct net_device *` —
`add_station`, `del_station`, `get_station`, `add_key`, `get_key`, `del_key`,
`cfg80211_new_sta`, `cfg80211_del_sta` all fail. Upstream's most recent
compatibility work targets **kernel 6.17**.

**It may well work on Debian**, which ships a 6.x kernel — the older distro is
the advantage here. Try it *after* the machine is online over ethernet; never
make it the only path to network, or you have a driver you cannot download
without the network it provides.

Note that this is out-of-tree kernel-space code from an unvetted repository.
Acceptable on a bench; think before putting it on a machine holding real work.

## Open items

- Confirm the RTX 2080 is physically supported on the open frame and visible in
  BIOS/OS; display has not yet been recorded from the installed OS.
- Board and RAM still recorded from build spec rather than from the machine.
- PM981a SMART never read — OEM drive, unknown hours.
- WiFi adapter unusable until either Debian's kernel proves compatible or
  upstream ports to 7.x.
- Machine directory created as `machines/testbench/` on 2026-09-04 **before the
  hostname was confirmed**. If Debian was installed under a different hostname,
  rename the directory and update `machines/machine-overview.md`.

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

## 2026-09-04, later — "frozen" machine diagnosed from the desktop

Operator reported the bench frozen. **It was not.** Probed from the desktop:

```
ping testbench.local        -> REACHABLE
ping 192.168.8.119          -> REACHABLE
ssh ef-tb@testbench.local   -> Permission denied (publickey,password)
```

That last line is the informative one: a `Permission denied` reply means
**`sshd` is running, listening, and authenticating.** Kernel, network stack and
SSH daemon are all healthy. Only the compositor / display-manager layer is
wedged — which is exactly the layer the NVIDIA/Sway work broke.

**Do not hard-reset a machine in this state.** Recovery:

- At the machine: `Ctrl+Alt+F2` (F3–F6 also) for a text console, then
  `sudo systemctl restart lightdm`, or `stop` it to work without it fighting.
- Or SSH in from anywhere with real credentials — the daemon is up.

**Generalise this.** "Frozen" on a headless-capable box is three distinct
states, and they have different responses:

| symptom | meaning | response |
|---|---|---|
| no ping | kernel hang or network down | hard reset is defensible |
| ping, no sshd | kernel alive, userspace badly broken | console, then investigate |
| **ping + sshd answering** | **only the GUI is stuck** | never reset; fix from a shell |

### Capture this before wiping for Ubuntu

The safe-revert script reported success — NVIDIA purged, `nouveau` loaded, only
plain `sway.desktop` present — yet Sway still misbehaved. **Whether that revert
actually completed is the one question worth answering before reinstalling**,
because if Sway is broken on *nouveau* too, the problem is not Debian and a
reinstall will not fix it.

```
systemctl is-active lightdm
journalctl -b -u lightdm --no-pager | tail -30
lsmod | grep -iE '^nvidia|^nouveau'
ls /usr/share/wayland-sessions/
```

### What was never actually broken

CUDA and `nvidia-smi` **worked** on Debian with driver `535.309.01` — the RTX
2080 was correctly reported. The failure was confined to Sway: Debian's Sway 1.7
refuses proprietary NVIDIA without `--unsupported-gpu`.

Those are separable problems, and **the one the bench actually needs — CUDA —
was already solved.** Do not carry "Debian couldn't do CUDA" into the Ubuntu
attempt; it isn't true.

### SSH access from the desktop

Not currently possible — no key installed, no `~/.ssh/config` entry, no
`known_hosts` record until this probe added one. To make the bench checkable
from the desktop (useful once 3090 work starts and walking over to it gets old),
run **on the bench**:

```
mkdir -p ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6M3UyGCRoGS5UzTPMA/HGma3HKVIOidjeFfZlO1ZBu blueaz@ionos' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

Worth doing **after** the Ubuntu install rather than before — it would not
survive the reinstall.

---

## 2026-09-04 — the revert completed and Sway still failed. It is not NVIDIA.

Operator confirmed the safe-revert script finished cleanly: NVIDIA packages
purged, `nouveau` loaded, only plain `sway.desktop` present. **Sway still did
not work.**

That rules out the proprietary driver as root cause. Sway is failing on
*nouveau*, which leaves two candidates:

1. **The config.** These dotfiles were copied from a Fedora desktop running a
   different Sway version. A parse error, or a missing binary in an `exec` line,
   makes Sway exit immediately — which LightDM presents as "bounced back to the
   login screen", exactly the observed symptom.
2. **The system.** Debian's Sway 1.7 / wlroots genuinely not working here.

**Only the second is fixed by reinstalling.** If it is the config, Ubuntu plus
the same `stow` reproduces the failure precisely, and an install has been spent
to reach the same screen.

Ruled out already: `outputs.conf.testbench` is a benign `output * scale 1` with
no connector names, so a nonexistent-output reference is not the cause.

### The test that settles it — 30 seconds, from a TTY

```
sudo systemctl stop lightdm
sway -c /dev/null
```

- **Bare Sway starts** → the fault is in the config. Reinstalling will not fix
  it; fixing the config will.
- **Bare Sway also fails** → system-level, and a reinstall is a reasonable
  response.

Either way, **the error Sway prints as it exits is the diagnostic.** Capture it.

### Process change for the Ubuntu install — three gates, in order

What made this hard to diagnose is that the dotfiles, the GPU driver and the
compositor all changed before any of them was confirmed working. Do not repeat
that. Confirm each gate before opening the next:

1. **Stock Sway logs in, with no dotfiles stowed at all.** Distro defaults only.
   Baseline established.
2. **`stow` the dotfiles. Confirm Sway still logs in.** If it breaks here, the
   config is the fault and you have isolated it in one step.
3. **Only then install NVIDIA**, via `ubuntu-drivers` rather than hand-assembled
   packages. Confirm `nvidia-smi`, then confirm Sway again.

If a gate fails, the cause is whatever you changed since the last passing gate.
That is the whole point.

**And keep the two goals separate.** CUDA is what this machine needs to do its
job, and CUDA already worked on Debian — it was never the broken part. Sway is
a workflow preference. Do not let a compositor problem block GPU work: the bench
is fully usable over SSH with no graphical session at all.

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

## 2026-09-04 — unplugging the WiFi dongle brought the machine back

**Operator pulled the AIC8800 dongle and the bench recovered.**

This is a stronger finding than "WiFi is not a boot dependency", which is what
this file previously recorded, and it deserves to be read as a lead rather than
a footnote.

### It may explain the entire Sway saga

Until now the failure needed three separate explanations: a display stack that
broke under proprietary NVIDIA, a revert that completed cleanly yet left Sway
broken anyway, and a machine that then would not come up at all. That is a lot
of independent faults for one evening.

**An out-of-tree kernel module misbehaving accounts for all three at once.** The
AIC8800 driver is unsigned third-party kernel-space code; it loads two modules
(`aic_load_fw`, `aic8800_fdrv`), and if it destabilises the kernel or hangs
during device probe, the symptom surfaces wherever the boot happens to be —
which is usually the compositor, because that is the heaviest thing starting at
that moment. It would also explain why purging NVIDIA and returning to nouveau
changed nothing: the driver was never the variable.

**Not proven.** This is one observation, and correlation. But it is a single
cause that fits every symptom, where the previous account needed three.

### Consequence — do not reinstall this driver by default

Its status changes from "useful extra" to **"suspected destabiliser, install
only deliberately and only after everything else is verified."**

On the Ubuntu install:

1. Complete the whole build **with the dongle physically unplugged.** Ethernet
   only.
2. Verify the baseline is stable: display manager, desktop session, reboot
   cycles, `nvidia-smi`.
3. **Only then**, if WiFi is actually wanted, plug it in and install the driver —
   as a discrete change, with a known-good state to fall back to.
4. If instability returns at that point, the answer is unambiguous.

**And the honest question first: does this machine need WiFi at all?** It sits
next to a wired connection, its job is GPU benchmarking, and it is driven over
SSH. The dongle has now cost more time than it has saved. Ethernet-only, no
dongle, headless or XFCE is very likely the correct permanent configuration —
which is where the operator landed independently.

The working WiFi details stay recorded above in case that changes. They were a
real result and worth keeping. Just do not let them pull the machine back into
this failure mode.

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

## 2026-09-05 — headless operational baseline confirmed

The bench is now in the intended stable mode: **mostly headless, Ethernet/SSH
first, XFCE only as local fallback, Sway out of scope.**

Confirmed from desktop:

```
ssh ef-tb@testbench.local 'hostname; whoami; nvidia-smi --query-gpu=name,driver_version --format=csv,noheader'
-> testbench
-> ef-tb
-> NVIDIA GeForce RTX 2080, 535.309.01
```

Current role guidance:

- Primary access: SSH from desktop/laptop.
- Primary network: wired Ethernet (`eno1`), DHCP currently `192.168.8.171`.
- WiFi/AIC8800: successful fallback experiment, but do not autoconnect by
  default; keep it out of suspend/wake path unless explicitly testing.
- Local GUI: XFCE/LightDM acceptable for emergencies and local maintenance.
- Sway: optional/manual experiment only; do not use as a gate for bench work.
- GPU/CUDA: NVIDIA driver 535.309.01 verified; CUDA smoke test passed.

Next hardening items, if desired:

1. Reserve `192.168.8.171` for `testbench` in the router/DHCP server, or assign
   a static IP intentionally.
2. Decide whether to keep `graphical.target` for convenience or switch to
   `multi-user.target` for true headless boot. For now, keeping XFCE is fine.
3. Install/enable Wake-on-LAN tooling (`ethtool`) if remote wake becomes useful.
4. Keep the USB backup current after major config changes.

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

## 2026-09-05 — RETRACTION: the dongle was not the cause either

**The recovery after unplugging the WiFi adapter was a false alarm.** The entry
above proposing the AIC8800 driver as the single explanation for the Sway
failures is **withdrawn**. It fit every symptom, which is exactly why it was
convincing, and it was still wrong.

**The root cause of the Debian Sway failure was never identified.** Three
theories were raised and all three died: the proprietary NVIDIA driver (revert
completed, Sway still broken), the dotfiles config (`outputs.conf` ruled out
benign), and the WiFi driver (retracted here). Do not carry any of them forward
as established.

That is the honest state. It is also, at this point, no longer worth chasing.

## Settled configuration — 2026-09-05

**Staying on Debian 12. XFCE. Headless. Ethernet.** No reinstall.

| | |
|---|---|
| OS | Debian 12 (bookworm), kernel `6.1.0-52-amd64` |
| Session | XFCE — stable, and not load-bearing since the machine is driven over SSH |
| Network | wired ethernet |
| WiFi | dongle out. Driver works but is not installed by default; see `ISSUES.md` |
| Sway | **abandoned on this machine.** Not worth further time; the desktop is where that workflow lives |
| Config | backed up by operator |
| Status | **ready for headless operation** |

The Ubuntu 24.04.4 USB was written and checksum-verified on 2026-09-04 and went
unused. Keep it — it costs nothing and the next time this machine needs
reinstalling it is already made.

### Why this is the right stopping point

The bench exists to validate the RM1000x and to host RTX 3090 configuration
work. Both are satisfied by a headless Debian box with CUDA. CUDA already
worked here (`nvidia-smi`, driver `535.309.01`, RTX 2080 correctly reported) —
Sway was the only thing that ever failed, and Sway is a workflow preference on a
machine nobody sits at.

An evening went into a compositor that this machine does not need. The
configuration it has now does the job it was built for.

### Next

GPU work. See `../parts/README.md` for the standing plan — the dual-3090
benchmark is the last gate on System 2's original purpose, and with two machines
available, single-GPU and dual-GPU configurations can now be held at the same
time instead of toggling a systemd override on the desktop.

Worth doing early: install the desktop's SSH key so this machine is reachable
from there without walking over to it. Command is in the SSH section above.
