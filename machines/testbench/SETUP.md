# Test Bench Debian Setup

Goal: configure the bench like the Fedora desktop where practical, while keeping
Debian and using the Debian-specific sway config.

## Access / discovery

From the bench itself, record:

```bash
hostnamectl --static
ip -4 addr show scope global
```

If remote setup is desired, install and enable SSH:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

## Base packages

```bash
sudo apt update
sudo apt install \
  git stow fastfetch neovim fzf ripgrep fd-find \
  sway swayidle swaylock waybar wofi dunst grim slurp wl-clipboard \
  terminator firefox-esr network-manager-gnome brightnessctl playerctl \
  pavucontrol pulseaudio-utils alsa-utils smartmontools dmidecode
```

## Dotfiles

```bash
git clone https://github.com/blue-az/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --no-folding apps bash sway-debian waybar i3 shared nvim xkb wallpaper
mkdir -p ~/.config/sway/config.d
ln -sf outputs.conf.testbench ~/.config/sway/config.d/outputs.conf
```

Use `sway-debian`, not `sway`: it uses Debian defaults like `wofi` and the
Debian wallpaper.

## Sway validation

From a TTY or display-manager Sway session:

```bash
swaymsg -t get_outputs
swaymsg reload
pkill -SIGUSR2 waybar || true
```

After `swaymsg -t get_outputs`, update
`../../sway-debian/.config/sway/config.d/outputs.conf.testbench` with the actual
connector name(s) if a fixed layout is needed.

## Hardware records to close open issues

```bash
sudo dmidecode -t baseboard -t memory | head -40
sudo smartctl -a /dev/nvme0n1 | grep -iE "model|power_on_hours|percentage_used|critical"
nvidia-smi || true
```

Record the results in `ISSUES.md` / `BUILD_HANDOFF.md`.

## Notes

- Wired ethernet is the reliable network path. The AIC8800 USB WiFi adapter is
  out-of-tree and should only be tried after ethernet works.
- The i3-9100F has no integrated graphics. All display output comes from the
  installed GPU.
