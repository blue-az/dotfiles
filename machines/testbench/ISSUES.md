# Test Bench — Issues

## RESOLVED 2026-09-04 — AIC8800 USB WiFi works on Debian 6.1

**The board has no onboard WiFi.** The MSI MPG Z390 **Gaming Plus** has none —
that is the *Gaming Edge AC* / *Pro Carbon AC* variants. A USB adapter was bought
to cover it. It **does work on this Debian install** with the RicknotDev
`aic8800d80` DKMS driver.

### The adapter

| | |
|---|---|
| Chipset | **aicsemi AIC8800** family |
| Initial USB ID | `a69c:5721` — fake USB mass-storage / driver-CD mode |
| Working USB ID | `368b:8d81` — `AICSemi AIC 8800D80` |
| Interface | `wlx8c773b23c4e9` |
| Mainline kernel support | **none** — out-of-tree DKMS driver required |

It ships in driver-CD mode and must be **mode-switched** before it presents as a
network interface — `usb_modeswitch`, or the udev rules the driver packages
install. The documented pattern for this family is
`usb_modeswitch -K -v a69c -p 5722`.

### Driver status, measured 2026-09-04

**Works here:** Debian 12, kernel `6.1.0-52-amd64`, using
`RicknotDev/aic8800d80` at commit `99822dc`. The adapter mode-switches from
`a69c:5721` to `368b:8d81`, loads `aic_load_fw` and `aic8800_fdrv`, and connects
through NetworkManager. With ethernet unplugged it held about **250 Mbps**, only
~40 Mbps below wired in the same spot.

Local setup helper kept at `~/setup-aic8800-wifi.sh`; source repo cloned at
`~/src/aic8800d80`.


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

### Rules

1. **Try it only after the machine is online over ethernet.** Never make this
   adapter the only path to network — you would need the network to download the
   driver that provides the network.
2. **This is out-of-tree kernel-space code from an unvetted repository.**
   Acceptable on a bench. Think before putting it on a machine holding real work.
3. If it works, **record the kernel version it worked on** — it will break on a
   kernel bump until upstream catches up, and DKMS will rebuild it against a
   kernel it may not support.

### Maintenance notes

- Keep wired ethernet as the recovery path.
- DKMS should rebuild on Debian kernel updates, but this driver is out-of-tree:
  verify WiFi after any kernel bump.
- Fedora/desktop kernel 7.x still needs an upstream port.
- If this ever becomes load-bearing, a dongle with mainline support is still the
  safer long-term answer.

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
