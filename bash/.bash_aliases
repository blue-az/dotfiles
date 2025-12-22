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
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# ls aliases
alias ll='ls -halF'
alias la='ls -A'
alias l='ls -CF'
#
# Virtual Environments
alias AVE="source ~/Python/.venv/bin/activate" # activate virtual environment
alias 313="source ~/.venv313/bin/activate" # activate virtual environment
alias CE="conda activate optiver_gpu"
alias OW="sudo docker rm -f open-webui || true && sudo docker run -d --network=host --gpus all -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda"

# Obsidian
alias Ob="flatpak run md.obsidian.Obsidian"

# Jupyter notebooks
alias jn="jupyter notebook"

# LLM
alias g3="ollama run gemma3:27b"
alias cl="claude"

# System info
alias ff="fastfetch"

# pycharm
alias pc="/opt/pycharm-2025.2.3/bin/pycharm"

# streamlit
alias sr="streamlit run streamlit_app.py"

# libreoffice calc
alias lc="libreoffice --calc"

# Wifi client
alias SF="sudo systemctl stop firewalld"
alias sH="nmcli device wifi hotspot ssid 'LinuxDisplay' password 'Erf123123!'"
alias SH="nmcli device disconnect wlp194s0"

alias sF="sudo systemctl start firewalld"
alias RW="nmcli device wifi connect 'da4e9a_5G'"
alias 5G="nmcli device wifi connect 'da4e9a_5G'"

alias Ei="nmcli device wifi list > /dev/null && nmcli device wifi connect 4A:0C:55:63:B9:EF"
alias nmlist="nmcli device wifi list"

alias Cc="nmcli device wifi connect 'LinuxDisplay' password 'Erf123123!'"


alias DE="~/Downloads/deskreen-ce-3.1.17-x86_64.AppImage"

# additional aliases
alias sbash='source ~/.bashrc'
alias 3off="xrandr --output HDMI-1 --off"
alias nv='nvidia-smi'

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

# Chromebook display aliases (AMD side - server)
alias cbe='~/cb-link/cb-display.sh extend'
alias cbm='~/cb-link/cb-display.sh mirror'
alias cbs='~/cb-link/cb-display.sh stop'
alias cbst='~/cb-link/cb-display.sh status'
alias cbt='~/cb-link/cb-display.sh toggle'
alias zof='sudo firewall-cmd --add-port=5900/tcp'
alias cbh='bat ~/Documents/cb-link-cheatsheet.txt'

# Chromebook display aliases (CB side - client, for CB machine only)
alias cbv='~/cb-link/cb-connect.sh'           # Quick viewer launch
alias cbc='~/cb-link/cb-connect.sh'           # Connect to AMD
alias cbcf='~/cb-link/cb-connect.sh f'        # Fullscreen connect
alias cbcm='~/cb-link/cb-connect.sh m'        # Mirror mode connect
alias cbcd='~/cb-link/cb-connect.sh d'        # Disconnect
alias cbcs='~/cb-link/cb-connect.sh s'        # Status
