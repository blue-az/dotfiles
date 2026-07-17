# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

# Auto-start Sway on TTY1 login
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
    exec sway
fi
. "$HOME/.cargo/env"


# Added by Antigravity CLI installer
export PATH="/home/blueaz/.local/bin:$PATH"
