# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# (bash-only due to history syntax)
if [ -n "$BASH_VERSION" ]; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# Alias definitions.
# ls aliases
alias ll='ls -halF'
alias la='ls -A'
alias l='ls -CF'
#
# Virtual Environments
alias AVE="source ~/Python/.venv/bin/activate" # activate virtual environment
alias 313="source ~/.venv313/bin/activate" # activate virtual environment
alias CE="conda activate aider-env"
alias Aid="aider --model gemini/gemini-2.0-flash --subtree-only"
alias OW="sudo docker rm -f open-webui || true && sudo docker run -d --network=host --gpus all -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda"

# Codex
alias UC="sudo npm install -g @openai/codex" # get latest version

# Z13 LED (rear lightbar)
alias rlo="sudo ~/.dotfiles/machines/z13-amd/led/z13-led --on"
alias rlof="sudo ~/.dotfiles/machines/z13-amd/led/z13-led --off"
alias rlr="sudo ~/.dotfiles/machines/z13-amd/led/z13-led --color 255 0 0"
alias rlg="sudo ~/.dotfiles/machines/z13-amd/led/z13-led --color 0 255 0"
alias rls="sudo ~/.dotfiles/machines/z13-amd/led/z13-window-cycle"
alias rlc="sudo ~/.dotfiles/machines/z13-amd/led/z13-window-step"

# Obsidian
alias Ob="flatpak run md.obsidian.Obsidian"

# Jupyter notebooks
alias jn="jupyter notebook"

# LLM
alias g3="ollama run gemma3:27b"
alias cl="claude"

# TennisAgent
alias TA="cd ~/Python/project-phoenix/domains/TennisAgent"

# Dotfiles directories
alias dc="cd ~/.dotfiles/machines/desktop"
alias zc="cd ~/.dotfiles/machines/z13-amd"
alias zwc="cd ~/.dotfiles/machines/z13-windows"

# System info
alias ff="fastfetch"

# pycharm
alias pc="/opt/pycharm-2025.2.3/bin/pycharm"

# streamlit
alias sr="streamlit run streamlit_app.py"

# libreoffice
alias lc="libreoffice --calc"
alias lw="libreoffice --writer"
alias fm="dolphin"

# Wifi client
alias SF="sudo systemctl stop firewalld"
alias sH="nmcli device wifi hotspot ssid 'LinuxDisplay' password ''"
alias SH="nmcli device disconnect wlp194s0"

alias sF="sudo systemctl start firewalld"
alias da4="nmcli device wifi connect 'da4e9a'"
alias 5G="nmcli device wifi connect 'da4e9a_5G'"

alias Ei="nmcli device wifi rescan; sleep 1; nmcli connection up \"iPhone\""
alias nmlist="nmcli device wifi list"

alias Cc="nmcli device wifi connect 'LinuxDisplay' password ''"


alias DE="~/Downloads/deskreen-ce-3.1.17-x86_64.AppImage"

# additional aliases
alias sb='source ~/.bashrc'
alias sbash='source ~/.bashrc'
alias 3off="xrandr --output HDMI-1 --off"
alias nv='nvidia-smi'

# Monitor refresh rate toggle (XB271HU)
alias 144='swaymsg output DP-2 mode 2560x1440@144Hz'
alias 60='swaymsg output DP-2 mode 2560x1440@60Hz'

# not used
alias XI="xrdb -merge ~/.Xresources"
alias dis="export DISPLAY=:0"
# Screen layouts (Sway/Wayland)
alias 1s="sh ~/.screenlayout/sway-1s.sh"
alias 2s="sh ~/.screenlayout/sway-2s.sh"
alias 3s="sh ~/.screenlayout/sway-3s.sh"
alias 3sp="sh ~/.screenlayout/sway-3sp.sh"
alias 4s="sh ~/.screenlayout/sway-4s.sh"
# X11 versions (commented out)
# alias 1s="sudo sh /home/blueaz/.screenlayout/1screen.sh"
# alias 2s="sudo sh /home/blueaz/.screenlayout/2s.sh"
# alias 3s="sudo sh /home/blueaz/.screenlayout/3screens.sh"

CB_LINK_HOME="${CB_LINK_HOME:-$HOME/Tools/cb-link}"
if [ ! -d "$CB_LINK_HOME" ] && [ -d "$HOME/cb-link" ]; then
    CB_LINK_HOME="$HOME/cb-link"
fi

# Chromebook display aliases (AMD side - server)
alias cbe="$CB_LINK_HOME/cb-display.sh extend"
alias cbm="$CB_LINK_HOME/cb-display.sh mirror"
alias cbmz="CB_LINK_OUTPUT=eDP-1 CB_LINK_MIRROR_RES=2560x1600 $CB_LINK_HOME/cb-display.sh mirror"
alias cbtog="$CB_LINK_HOME/cb-display.sh toggle"
alias cbs="$CB_LINK_HOME/cb-display.sh stop"
alias cbst="$CB_LINK_HOME/cb-display.sh status"
alias cbmr="cbm && cbt"                       # Start mirror mode then push to tablet over USB
alias cbt="$CB_LINK_HOME/cb-tablet.sh"
alias cbts="$CB_LINK_HOME/cb-tablet.sh stop"
alias zof='sudo firewall-cmd --add-port=5900/tcp'
# Use bat if available, otherwise cat
if command -v bat &> /dev/null; then
    alias cbh="bat $CB_LINK_HOME/cb-link-cheatsheet.txt"
else
    alias cbh="cat $CB_LINK_HOME/cb-link-cheatsheet.txt"
fi

# Chromebook display aliases (CB side - client, for CB machine only)
alias cbv="$CB_LINK_HOME/cb-connect.sh"           # Quick viewer launch
alias cbc="$CB_LINK_HOME/cb-connect.sh"           # Connect to AMD
alias cbcf="$CB_LINK_HOME/cb-connect.sh f"        # Fullscreen connect
alias cbcm="$CB_LINK_HOME/cb-connect.sh m"        # Mirror mode connect
alias cbcd="$CB_LINK_HOME/cb-connect.sh d"        # Disconnect
alias cbcs="$CB_LINK_HOME/cb-connect.sh s"        # Status

alias cbel="HEADLESS_RES=1280x800 $CB_LINK_HOME/cb-display.sh extend"
alias cbml="HEADLESS_RES=1280x800 $CB_LINK_HOME/cb-display.sh mirror"
