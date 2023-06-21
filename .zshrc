# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd notify interactivecomments
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
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

function chpwd() {
    emulate -L zsh
    update_kitty_tab_title
    eval ls
}

function update_kitty_tab_title() {
    if [ "$cur_term" = "kitty" ]; then
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
function get_term () {
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
    python3 -c "from math import *; print($*)"
}

# create dir and cd
function mkcd (){
    mkdir -p "$1" && cd "$1"
}

# Switch between git worktrees.
function wt () {
    if [[ "$1" =~ ^(list|version|update|help)$ ]]; then
        eval "$(whence -p wt)" $@
    else
        local s="$("$(whence -p wt)" -e $@)"
        local code=$?

        if [ $code -eq 0 ]; then
            eval "$s"
        else
            exit $code
        fi
    fi
}

function man_color () {
    LESS_TERMCAP_mb=$'\e[1;32m' \
    LESS_TERMCAP_md=$'\e[1;32m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[1;30;46m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;4;33m' \
    /usr/bin/man $@
}

# Commit and push changes to dotfiles
# @param $1 Optional commit message
function dfcp () {
    if ! eval dotfiles diff-index --quiet HEAD; then
        local commit_msg="Update"
        if [ ! -z "$1" ]; then
            commit_msg="$1"
        fi
        eval dotfiles add -u && eval dotfiles status && \
            eval dotfiles commit -m "$commit_msg" && eval dotfiles push
    else
        echo "No dotfiles have been modified."
    fi
}

function dark_theme() { echo "default_dark" > /tmp/terminal_theme; update_theme }
function light_theme() { echo "default_light" > /tmp/terminal_theme; update_theme }

function update_theme() {
    if [ -e /tmp/terminal_theme ]; then
        local name="$(head -n1 < /tmp/terminal_theme)"
        if [ "$name" = "default_dark" ]; then
            export NVIM_COLORSCHEME="default_dark"
            if [ "$cur_term" = "kitty" ]; then
                kitty @ set-colors ~/.config/kitty/colors/catppuccin-mocha.conf
            fi
        elif [ "$name" = "default_light" ]; then
            export NVIM_COLORSCHEME="default_light"
            if [ "$cur_term" = "kitty" ]; then
                kitty @ set-colors ~/.config/kitty/colors/seoulbones_light.conf
            fi
        fi
    fi
}

function nv-helptags() {
    nvim --headless --clean -u NORC \
        -c "helptags $([ -n "$1" ] && echo "$1" || echo doc)" \
        -c "qa"
}

function soenv() {
    [[ -z "$1" ]] && set -- ".env"

    for f in $@; do
        set -a
        source "$f"
        set +a
    done
}

cur_term="$(get_term)"
update_theme


export NEOFETCH_IMG="$HOME/GoogleDrive/sindrets@gmail.com/Bilder/neofetch/"
export BROWSER=/usr/bin/firefox-beta
export LC_ALL=en_US.UTF-8 # force all applications to use default language for output
export LESS=-r # scroll pager with mouse wheel.
export KEYTIMEOUT=1 # zsh character sequencce wait (in 0.1s)
export NODE_PATH=/usr/lib/node_modules
export GIT_DIRECTORY="$HOME/Documents/git"
export MANWIDTH=80 # text width in man pages
export MANPAGER="$(which nvim) -nc 'setl nolist scl=yes:1 | lua Config.lib.set_center_cursor(true)' +Man! -"

if [ ! "$cur_term" = "nvim" ]; then
    export VISUAL=nvim
    export EDITOR=nvim
fi

eval `dircolors "$HOME/.dir_colors"`

# --- Plugins ---
source /usr/share/zsh/share/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle softmoth/zsh-vim-mode@main
antigen bundle zsh-vi-more/evil-registers
antigen bundle mafredri/zsh-async
antigen bundle sindresorhus/pure@main

antigen apply
# ---------------

# find escape codes with "showkey -a"
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey -M viins '^[[1;5D' backward-word  # Ctrl-left
bindkey -M viins '^[[1;5C' forward-word  # Ctrl-right
bindkey -M vicmd '^[[1;5D' backward-word  # Ctrl-left
bindkey -M vicmd '^[[1;5C' forward-word  # Ctrl-right
bindkey -M viins '^[[3~' delete-char  # delete key
bindkey "^?" backward-delete-char

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

[ -f "$HOME/.bashrc.aliases" ] && source "$HOME/.bashrc.aliases"

if [ -x "$(command -v exa)" ]; then
    alias ls='exa --group-directories-first'
    alias la='exa --group-directories-first -a'
    alias ll="exa --group-directories-first -lh --git"
    alias lla="exa --group-directories-first -lha --git"
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
alias gll="git log --stat=80"
alias dgs="dotfiles status -sb"
alias dgd="dotfiles diff"
alias dgl="dotfiles log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an> %Cgreen(%cr)%Creset' --abbrev-commit"
alias dgll="dotfiles log --stat=80"
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias tree="exa --tree --icons --group-directories-first"
alias ip="ip -c -h"
alias h="cd ~"
alias g="cd $GIT_DIRECTORY"
alias m="cd ~/Documents/misc"
alias r="source ~/.zshrc"
alias nv="nvim"
alias nvim-conf="nvim --cmd 'cd ~/.config/nvim' -c 'args %' ~/.config/nvim/init.lua \
    ~/.config/nvim/lua/user/plugins/init.lua"
alias nv-conf="nvim-conf"
alias nvim-pager="nvim -Rnc 'set bt=nowrite noswapfile ul=-1 nolist nonu nornu scl=yes:1 | lua Config.lib.set_center_cursor(true)'"
alias nv-pager="nvim-pager"
alias vim-conf="$EDITOR ~/.vimrc"
alias bash-conf="$EDITOR ~/.bashrc"
alias zsh-conf="$EDITOR ~/.zshrc"
alias kitty-conf="$EDITOR ~/.config/kitty/kitty.conf"
alias rmorphans='yay -Rs $(yay -Qqdt)'
alias npmls="cat package.json | jq .scripts"
alias pls="sudo "
alias daddy="systemctl"
alias kys="systemctl poweroff"
alias rankmirrors="sudo reflector --verbose --latest 100 --sort rate --save \
    /etc/pacman.d/mirrorlist"
alias mdv="mdvless"
alias nvminit="source /usr/share/nvm/init-nvm.sh"
alias diff='diff -tW $(tput cols) --color=always'
alias ts-node='/bin/ts-node --project "$HOME/.config/ts-node/tsconfig.json"'
alias cw='code_dir=`jq -rM ".openedPathsList.workspaces3[]" "$HOME/.config/Code/storage.json" \
    | fzf --height 10` && [ ! -z "$code_dir" ] && code --folder-uri $code_dir'
alias tsall="find -maxdepth 1 -name 'tsconfig*.json' -exec sh -c 'echo \"Compiling for {}...\" \
    && tsc -p {}' \\;"
alias cal="/usr/bin/cal -mw"

# init fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard | fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_DEFAULT_OPTS="-1 --reverse --multi --color=16 --preview='[[ \$(file --mime {}) =~ binary ]] && \
echo {} is a binary file || (bat -n --color=always {} || cat {}) 2> /dev/null | head -300' \
--preview-window='right:hidden:wrap' --bind='\
f3:execute(bat -n {} || less -f {}),\
f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up'"

_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Use block shape cursor
# function fix_cursor() {
#    echo -ne '\e[1 q'
# }

# precmd_functions+=(fix_cursor)

# source .sh_extra if it exists
[ -e "$HOME/.sh_extra" ] && source "$HOME/.sh_extra"

# init pure prompt
autoload -U promptinit; promptinit
zstyle :prompt:pure:git:stash show yes
zstyle :prompt:pure:prompt:success color green
export PURE_PROMPT_SYMBOL="ᐅ"
export PURE_PROMPT_VICMD_SYMBOL="λ"
prompt pure

read -rd '' aperture_logo <<'EOF'
\e[1;33m              .,-:;//;:=,
          . :H@@@MM@M#H/.,+%;,
       ,/X+ +M@@M@MM%=,-%HMMM@X/,
     -+@MM; $M@@MH+-,;XMMMM@MMMM@+-
    ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/.
  ,%MM@@MH ,@%=             .---=-=:=,.
  =@#@@@MX.,                -%HX$$%%%:;
 =-./@M@M$                   .;@MMMM@MM:
 X@/ -$MM/                    . +MM@@@M$
,@M@H: :@:                    . =X#@@@@-
,@@@MMX, .                    /H- ;@M@M=
.H@@@@M@+,                    %MM+..%#$.
 /MMMM@MMH/.                  XM@MH; =;
  /%+%$XHH@$=              , .H@@@@MX,
   .=--------.           -%H.,@@@@@MX,
   .%MM@@@HHHXX$$$%+- .:$MMX =M@@MM%.
     =XMMM@MM@MM#H;,-+HMM@M+ /MMMX=
       =%@M@M#@$-.=$@MM@@@M; %M%=
         ,:+$+-,/H#MMMMMMM@= =,
               =++%%%%+/:-.\e[0m
EOF

alias neofetch='/usr/bin/neofetch --ascii "$(echo $aperture_logo)"'

case $cur_term in

    "konsole") ;;

    "kitty") 
        # Enable blurred transparency for Kitty
        if [[ $(ps --no-header -p $PPID -o comm | grep -Ev '^(yakuake|konsole)$' ) ]]; then
            for wid in $(xdotool search --pid $PPID); do
                xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $wid; done
        fi

        # Change neofetch img backend and source
        if [[ -f "$NEOFETCH_IMG" || -d "$NEOFETCH_IMG" ]]; then
            alias neofetch='printf %$(tput lines)s | tr " " "\n"; /usr/bin/neofetch --backend kitty --source "$NEOFETCH_IMG" && printf "\e[2A"'
        fi
        ;;

esac

# post init
update_kitty_tab_title
if  [ ! $UID = 0 ] &&
    [ ! $cur_term = "init" ] &&  # WSL
    [ ! $cur_term = "code" ] &&   # vscode
    [ ! $cur_term = "nvim" ];
then
    eval neofetch
fi

# vim: sw=4


# BEGIN_KITTY_SHELL_INTEGRATION
if test -e "/usr/lib/kitty/shell-integration/kitty.zsh"; then source "/usr/lib/kitty/shell-integration/kitty.zsh"; fi
# END_KITTY_SHELL_INTEGRATION
