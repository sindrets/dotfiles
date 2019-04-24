#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

BROWSER=/usr/bin/chrome
export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=C # force all applications to use default language for output

alias ls='ls --color=auto'
alias ll="ls -lh"
alias ipinfo="curl https://ipinfo.io/ip"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias tree="tree -C"
alias h="cd ~"
alias cd="cs"
alias nvim-conf="$EDITOR ~/.config/nvim/init.vim"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"

# Change directory and ls
function cs () {
	builtin cd "$@" && ls
}

# Resolve and print path
function rpath () {
	local RELATIVE_PATH=$1
	printf $(readlink -f $RELATIVE_PATH)
}

# PS1='[\u@\h \W]\$ '
PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \W\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"

