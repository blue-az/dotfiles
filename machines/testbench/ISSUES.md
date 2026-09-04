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
