# ~/.zshrc - adapted from Linux dotfiles for macOS

# Path
export PATH="$HOME/.local/bin:$PATH"

# History settings
HISTSIZE=1000
SAVEHIST=2000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Enable vi mode for command-line editing
bindkey -v

# Reduce mode switch delay
export KEYTIMEOUT=1

# Set nvim as default editor
export EDITOR=nvim
export VISUAL=nvim

# Aliases - ls
alias ll='ls -halF'
alias la='ls -A'
alias l='ls -CF'

# Aliases - grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Virtual Environments
alias AVE="source ~/Python/.venv/bin/activate"
alias 313="source ~/.venv313/bin/activate"

# Jupyter notebooks
alias jn="jupyter notebook"

# LLM
alias cl="claude"

# System info
alias ff="fastfetch"

# Reload shell config
alias szsh='source ~/.zshrc'
alias sbash='source ~/.zshrc'  # muscle memory from Linux

# Source shared bash aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# fzf integration (only source once to avoid re-eval errors)
if [ -f ~/.fzf.zsh ] && ! typeset -f fzf-history-widget > /dev/null; then
    source ~/.fzf.zsh
fi

# Prompt - simple with git info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f$ '
