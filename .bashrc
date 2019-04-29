#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH=~/.config/scripts:$PATH

export NEOFETCH_IMG="/home/sindrets/Google Drive/sindrets@gmail.com/Bilder/neofetch/"

BROWSER=/usr/bin/chrome
export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=en_US.UTF-8 # force all applications to use default language for output

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
alias r="source ~/.bashrc"
alias nvim-conf="$EDITOR ~/.config/nvim/init.vim"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"
alias rmorphans="yay -Rs $(yay -Qqdt)"

# Change directory and ls
function cs () {
	builtin cd "$@" && ls
}

# Resolve and print path
function rpath () {
	local RELATIVE_PATH=$1
	printf "$(readlink -f "$RELATIVE_PATH")"
}

# Get current terminal emulator
function getTerm () {
	local TERM_BIN=$(ps -p $(ps -p $$ -o ppid=) o args=)
	perl -e 'print ( $ARGV[0] =~ /((?<=\/)[^\/]*$)/ )' $TERM_BIN
}

term="$(getTerm)"
case $term in

	"konsole") ;;

	"kitty") 
		# Enable blurred transparency for Kitty
		if [[ $(ps --no-header -p $PPID -o comm | grep -Ev '^(yakuake|konsole)$' ) ]]; then
			for wid in $(xdotool search --pid $PPID); do
				xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $wid; done
		fi

		# Change neofetch img backend and source
		[[ -f "$NEOFETCH_IMG" || -d "$NEOFETCH_IMG" ]] && alias neofetch="neofetch --backend kitty --source '$NEOFETCH_IMG'"
		;;

esac 

# PS1='[\u@\h \W]\$ '
PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \W\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh

# POST INIT
neofetch

