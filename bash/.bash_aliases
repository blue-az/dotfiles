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
alias UG="sudo npm install -g @google/gemini-cli@latest"

# Obsidian
alias Ob="flatpak run md.obsidian.Obsidian"

# Jupyter notebooks
alias jn="jupyter notebook"

# LLM
alias g3="ollama run gemma3:27b"
alias os="nohup ollama serve >/tmp/ollama.log 2>&1 &"
alias cl="claude"
alias opr="/home/blueaz/operator-control-plane/opr"

# Claude Code mode switches
# lcc: local Claude Code via Ollama/Gemma
# acc: Anthropic API Claude Code
# scc: subscription/OAuth Claude Code
alias lcc='source ~/Tools/Claude-Switch/bin/claude-local-mode'
alias acc='source ~/Tools/Claude-Switch/bin/claude-api-mode'
alias scc='source ~/Tools/Claude-Switch/bin/claude-sub-mode'
alias ccs='~/Tools/Claude-Switch/bin/claude-mode-status'
alias 26b='~/Tools/Claude-Switch/bin/cc-local --model gemma4:26b'

# TennisAgent
alias PP="cd ~/Python/project-phoenix"
alias TA="cd ~/Python/project-phoenix/domains/TennisAgent"

# Dotfiles directories
alias dc="cd ~/.dotfiles/machines/desktop"
alias zc="cd ~/.dotfiles/machines/z13-amd"
alias zwc="cd ~/.dotfiles/machines/z13-windows"

# System info
alias ff="fastfetch"
alias ffp="fastfetch --pipe false | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/***.***.***.***/g'"

# pycharm
alias pc="/opt/pycharm-2025.2.3/bin/pycharm"

# streamlit
alias sr="streamlit run streamlit_app.py"

# libreoffice
alias lc="libreoffice --calc"
alias lw="libreoffice --writer"
alias fm="dolphin"

alias DE="~/Downloads/deskreen-ce-3.1.17-x86_64.AppImage"

# additional aliases
alias sb='source ~/.bashrc'
alias sbash='source ~/.bashrc'
alias 3off="xrandr --output HDMI-1 --off"
alias nv='nvidia-smi'
alias 200='sudo nvidia-smi -pl 200'

# openwiki against local Ollama (config in ~/.openwiki/.env; base URL can't be persisted there)
alias openwiki='OPENAI_BASE_URL=http://localhost:11434/v1 openwiki'

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

_dotfiles_machine="${DOTFILES_MACHINE:-$(hostname 2>/dev/null)}"
case "$_dotfiles_machine" in
    fedora|z13) _dotfiles_machine="z13-amd" ;;
esac

if [ -n "$_dotfiles_machine" ] && [ -f "$HOME/.dotfiles/machines/$_dotfiles_machine/bash_aliases" ]; then
    . "$HOME/.dotfiles/machines/$_dotfiles_machine/bash_aliases"
fi
unset _dotfiles_machine
