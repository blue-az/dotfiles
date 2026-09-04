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
