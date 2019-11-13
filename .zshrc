# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd notify
unsetopt beep
bindkey -v  # vi mode
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select=0
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/sindrets/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


export NEOFETCH_IMG="/home/sindrets/Google Drive/sindrets@gmail.com/Bilder/neofetch/"
export BROWSER=/usr/bin/firefox
export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=en_US.UTF-8 # force all applications to use default language for output
export LESS=-r # scroll pager with mouse wheel.
export KEYTIMEOUT=1 # zsh character sequencce wait (in 0.1s)

# find escape codes with "showkey -a"
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey -M viins '^[[1;5D' backward-word  # Ctrl-left
bindkey -M viins '^[[1;5C' forward-word  # Ctrl-right
bindkey -M vicmd '^[[1;5D' backward-word  # Ctrl-left
bindkey -M vicmd '^[[1;5C' forward-word  # Ctrl-right
bindkey -M viins '^[[3~' delete-char  # delete key
bindkey "^?" backward-delete-char

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

[[ -f "./.bashrc.aliases" ]] && source "./.bashrc.aliases"

alias ls='ls --color=auto'
alias ll="ls -lh"
alias lla="ls -lha"
alias grep="grep --color"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias tree="tree -C"
alias h="cd ~"
alias g="cd ~/Documents/git"
alias m="cd ~/Documents/misc"
alias r="source ~/.zshrc"
alias nvim-conf="$EDITOR ~/.config/nvim/init.vim"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"
alias zsh-conf="$EDITOR ~/.zshrc"
alias rmorphans='yay -Rs $(yay -Qqdt)'
alias npmls="cat package.json | jq .scripts"
alias pls="sudo "
alias daddy="systemctl"
alias kys="systemctl poweroff"
alias rankmirrors="sudo reflector --verbose --latest 100 --sort rate --save /etc/pacman.d/mirrorlist"
alias mdv="mdvless"
alias man="man-color"
alias nvminit="source /usr/share/nvm/init-nvm.sh"

function chpwd() {
	emulate -L zsh
	updateKittyTabTitle
	ls
}

function updateKittyTabTitle() {
	if [ "$term" = "kitty" ]; then
		kitty @ set-tab-title `basename "$(pwd)"`
	fi
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

function mdvless () {
	/usr/bin/mdv $@ | less
}

# calculator
function = () {
	python -c "from math import *; print($*)"
}

function man-color () {
	LESS_TERMCAP_mb=$'\e[1;32m' \
	LESS_TERMCAP_md=$'\e[1;32m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_se=$'\e[0m' \
	LESS_TERMCAP_so=$'\e[01;33m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[1;4;31m' \
	/usr/bin/man $@
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
		if [[ -f "$NEOFETCH_IMG" || -d "$NEOFETCH_IMG" ]]; then
			alias neofetch='printf %$(tput lines)s | tr " " "\n"; neofetch --backend kitty --source "$NEOFETCH_IMG"'
		fi
		;;

esac


# syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# init powerline
powerline-daemon -q
. /usr/share/powerline/bindings/zsh/powerline.zsh

# post init
updateKittyTabTitle
if	[ ! $UID = 0 ] &&
	[ ! $term = "init" ]  # WSL
	[ ! $term = "code" ];   # vscode
then
	neofetch
fi

