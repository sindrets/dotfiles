#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH=~/.config/scripts:$PATH

export NEOFETCH_IMG="/home/sindrets/Google Drive/sindrets@gmail.com/Bilder/neofetch/"

BROWSER=/usr/bin/google-chrome-stable
export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=en_US.UTF-8 # force all applications to use default language for output

[[ -f "./.bashrc.aliases" ]] && source "./.bashrc.aliases"

alias ls='ls --color=auto'
alias ll="ls -lh"
alias lla="ls -lha"
alias grep="grep --color"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias tree="tree -C"
alias cd="cs"
alias popd="popd_wrap" 
alias h="cd ~"
alias g="cd ~/Documents/git"
alias m="cd ~/Documents/misc"
alias r="source ~/.bashrc"
alias nvim-conf="$EDITOR ~/.config/nvim/init.vim"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"
alias rmorphans='yay -Rs $(yay -Qqdt)'
alias npmls="cat package.json | jq .scripts"
alias pls="sudo "
alias daddy="systemctl"
alias kys="systemctl poweroff"
alias rankmirrors="sudo reflector --verbose --latest 100 --sort rate --save /etc/pacman.d/mirrorlist"

# Change directory and ls
function cs () {
	builtin cd "$@" && ls && chpwd_hook
}

function popd_wrap () {
	builtin popd "$@" && chpwd_hook
}
# Resolve and print path
function rpath () {
	local RELATIVE_PATH="${@: -1}"
	printf "$(realpath -ms "$RELATIVE_PATH")"
	[ "$1" != "-n" ] && printf "\n"
}

# Get current terminal emulator
function getTerm () {
	local sid=$(ps -o sid= -p "$$")
	local sid_int=$((sid)) # strips blanks if any
	local session_leader_parent=$(ps -o ppid= -p "$sid_int")
	local session_leader_parent_int=$((session_leader_parent))
	echo $(ps -o comm= -p "$session_leader_parent_int")
}

# Toggle VPN
function vpn () {
	if nordvpn status | grep -iq disconnected; then
		nordvpn c no
	else
		nordvpn d
	fi
}

term="$(getTerm)"

function chpwd_hook() {
	if [ $term == "kitty" ]; then
		kitty @ set-tab-title `basename "$(pwd)"`
	fi
}

case $term in

	"konsole") ;;

	"kitty") 
		# Enable blurred transparency for Kitty
		if [[ $(ps --no-header -p $PPID -o comm | grep -Ev '^(yakuake|konsole)$' ) ]]; then
			for wid in $(xdotool search --pid $PPID); do
				xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $wid; done
		fi

		# Change neofetch img backend and source
		if [[ -f "$NEOFETCH_IMG" || -d "$NEOFETCH_IMG" ]]; then
			alias neofetch='printf %$(tput lines)s | tr " " "\n"; neofetch --backend kitty --source "$NEOFETCH_IMG"'
		fi
		;;

esac 

# PS1='[\u@\h \W]\$ '
PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \W\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh

eval $(thefuck --alias)

# POST INIT
chpwd_hook
neofetch

