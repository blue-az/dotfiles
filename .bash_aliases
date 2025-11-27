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

# Jupyter notebooks
alias jn="jupyter notebook"

# LLM
alias g3="ollama run gemma3:27b"

# pycharm
alias pc="/opt/pycharm-2025.2.3/bin/pycharm"

# streamlit
alias sr="streamlit run streamlit_app.py"

# libreoffice calc
alias lc="libreoffice --calc"

# additional aliases
alias sbash='source ~/.bashrc'
alias 3off="xrandr --output HDMI-1 --off"
alias nv='nvidia-smi'

# not used
alias XI="xrdb -merge ~/.Xresources"
alias dis="export DISPLAY=:0"
alias 1s="sudo sh /home/blueaz/.screenlayout/1screen.sh"
alias 2s="sudo sh /home/blueaz/.screenlayout/2s.sh"
alias 3s="sudo sh /home/blueaz/.screenlayout/3screens.sh"
alias 3sp="sudo sh /home/blueaz/.screenlayout/3screensPlus.sh"
alias 4s="sudo sh /home/blueaz/.screenlayout/4screens.sh"
