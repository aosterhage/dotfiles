# If not already set, set XDG directories to their defaults (to help interoperability on Windows)
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:=$HOME/.local/state}"

# Set the prompt
export PS1=export PS1="\@ \w > "

# Make an alias for managing the dotfiles bare repository
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
