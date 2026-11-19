#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export VISUAL=nvim
export EDITOR=nvim
export LC_ALL=en_US.UTF-8 # force all applications to use default language for output
export LESS=-r # scroll pager with mouse wheel.

[[ -f "./.bashrc.aliases" ]] && source "./.bashrc.aliases"

if [ -x "$(command -v eza)" ]; then
    alias ls='eza --group-directories-first'
    alias la='eza --group-directories-first -a'
    alias ll="eza --group-directories-first -lh"
    alias lla="eza --group-directories-first -lha"
else
    alias ls='ls --group-directories-first --color=always'
    alias la='ls --group-directories-first -a'
    alias ll="ls --group-directories-first -lh"
    alias lla="ls --group-directories-first -lha"
fi

alias grep="grep --color"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias editdots='(cd ~ > /dev/null && GIT_DIR="~/.dotfiles" nvim +"Git ++curwin")'
alias gs="git status -sb"
alias gd="git diff"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an> %Cgreen(%cr)%Creset' --abbrev-commit"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an> %Cgreen(%cr)%Creset%n%b' --abbrev-commit --stat"
alias dgs="dotfiles status -sb"
alias dgd="dotfiles diff"
alias dgl="dotfiles log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an> %Cgreen(%cr)%Creset' --abbrev-commit"
alias dgll="dotfiles log --stat=80"
alias tree="exa --tree --icons --group-directories-first"
alias ip="ip -c -h"
alias h="cd ~"
alias g="cd $GIT_WORKSPACE"
alias m="cd ~/Documents/misc"
alias r="source ~/.zshrc"
alias ta="tmux a -t"
alias nv="nvim"
alias nvclean="nvim --clean -u NORC"
alias nvim-conf="GIT_DIR=$HOME/.dotfiles nvim --cmd 'cd ~/.config/nvim' -c 'args %' \
    ~/.config/nvim/init.lua ~/.config/nvim/lua/user/plugins/init.lua"
alias nv-conf="nvim-conf"
alias nvim-pager="nvim -Rnc 'set bt=nowrite noswapfile ul=-1 nolist nonu nornu scl=yes:1 | lua Config.lib.set_center_cursor(true)'"
alias nv-pager="nvim-pager"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"
alias zsh-conf="$EDITOR ~/.zshrc"
alias kitty-conf="$EDITOR ~/.config/kitty/kitty.conf"
alias rmorphans='yay -Rs $(yay -Qqdt)'
alias npmls="jq .scripts package.json"
alias rankmirrors="sudo reflector --verbose --latest 100 --sort rate --save \
    /etc/pacman.d/mirrorlist"
alias mdv="mdvless"
alias nvminit="source /usr/share/nvm/init-nvm.sh"
alias diff='diff -tW $(tput cols) --color'
alias cw='code_dir=`jq -rM ".openedPathsList.workspaces3[]" "$HOME/.config/Code/storage.json" \
    | fzf --height 10` && [ ! -z "$code_dir" ] && code --folder-uri $code_dir'
alias tsall="find -maxdepth 1 -name 'tsconfig*.json' -exec sh -c 'echo \"Compiling for {}...\" \
    && tsc -p {}' \\;"
alias cal="/usr/bin/cal -mw"
alias tlmgr="tlmgr --usermode"
alias notes="zk edit -i --sort=created"
alias ff="fastfetch"

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

function chpwd_hook() {
	if [ "$term" == "kitty" ]; then
		kitty @ set-tab-title `basename "$(pwd)"`
	fi
}

# PS1='[\u@\h \W]\$ '
PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \W\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"

# POST INIT
chpwd_hook
