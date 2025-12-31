# Acer Predator XB271HU

27" IPS Gaming Monitor, 2560x1440, 144Hz (165Hz overclock)

## Specs
- Panel: IPS, 27"
- Resolution: 2560x1440 (WQHD)
- Refresh: 144Hz native, 165Hz overclocked (DisplayPort only)
- G-Sync: Yes (hardware module)
- Inputs: DisplayPort 1.2, HDMI 1.4
- Connection: DP-2 on desktop

## Sway Output
```
output DP-2 pos 1680 0 mode 2560x1440@60Hz
```

## Power vs Refresh Rate (Nvidia RTX 3090)
| Refresh | GPU Idle Power | GPU State | GPU Clocks |
|---------|----------------|-----------|------------|
| 60Hz    | ~40W           | P8        | 330 MHz    |
| 144Hz   | ~160W          | P0        | 1965 MHz   |

**Note:** High refresh rates prevent Nvidia GPUs from entering low power states on Linux. Use 60Hz for desktop work, 144Hz for gaming.

## OSD Menu

### Button Layout
5 unlabeled buttons on bottom-right edge + power button (far right).
Buttons are finicky - may need multiple presses.

### Menu Structure
| Menu | Settings |
|------|----------|
| **Picture** | Brightness, Contrast, Blue Light, Dark Boost |
| **Color** | Gamma, Color Temp, sRGB, 6-Axis Color |
| **OSD** | Language, Timeout, Refresh rate num (shows Hz), Transparency |
| **Settings** | Input, Wide Mode, OverClock (144->165Hz), ULMB, Deep Sleep, Reset |
| **Information** | Current resolution, refresh rate, mode |

### Key Settings
- **OverClock**: Only bumps 144Hz to 165Hz (doesn't affect 60Hz option)
- **Refresh rate num**: Shows current Hz on screen (useful for debugging)
- **ULMB**: Ultra Low Motion Blur (mutually exclusive with G-Sync)
- **Deep Sleep**: Power saving when no signal

### DDC/CI
Does NOT respond to DDC brightness control (ddcutil). Use OSD for brightness.

## Toggle Aliases
```bash
alias 144='swaymsg output DP-2 mode 2560x1440@144Hz'
alias 60='swaymsg output DP-2 mode 2560x1440@60Hz'
```

## Sources
- [Legit Reviews - OSD Details](https://www.legitreviews.com/acer-predator-xb1-xb271hu-wqhd-2560x1440-144hz-g-sync-monitor-review_184001/2)
- [Acer Community](https://community.acer.com)
