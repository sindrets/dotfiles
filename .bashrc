#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH=~/.config/scripts:$PATH

BROWSER=/usr/bin/chrome
export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=C # force all applications to use default language for output

[[ -f "./.bashrc.aliases" ]] && source "./.bashrc.aliases"

alias ls='ls --color=auto'
alias ll="ls -lh"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias tree="tree -C"
alias cd="cs"
alias h="cd ~"
alias g="cd ~/Documents/git"
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

