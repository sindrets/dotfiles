#!/usr/bin/sh

# Set our umask
umask 022

export XDG_CONFIG_HOME="$HOME/.config"
export VISUAL=nvim
export EDITOR=nvim
export BROWSER=/usr/bin/firefox-beta
export TERMINAL=kitty
export GREP_COLORS='ms=01;33:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
export npm_config_prefix="$HOME/.local"
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

appendenv () {
    local var_name="$1"
    local value="$(eval "echo \${$var_name}")"

    if [ ! -z "$value" ]; then
        eval "$(printf '%q' "$1"="$value:$2")"
    else
        eval "$(printf '%q' "$1"="$2")"
    fi
}

prependenv () {
    local var_name="$1"
    local value="$(eval "echo \${$var_name}")"

    if [ ! -z "$value" ]; then
        eval "$(printf '%q' "$1"="$2:$value")"
    else
        eval "$(printf '%q' "$1"="$2")"
    fi
}

# Append our default paths
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$(realpath -sm "$1")"
    esac
}

prependpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="$(realpath -sm "$1")${PATH:+:$PATH}"
    esac
}

prependpath "$HOME/.local/sbin"
prependpath "$HOME/.local/bin"
prependpath "$HOME/.config/scripts"
appendpath '/usr/local/sbin'
appendpath '/usr/local/bin'
appendpath '/usr/bin'
appendpath "$HOME/.config/emacs/bin"
appendpath "$(ruby -e 'puts Gem.user_dir')/bin"
appendpath "$HOME/.cargo/bin"

export PATH

appendenv XCURSOR_PATH "$(realpath -m /usr/share/icons)"
appendenv XCURSOR_PATH "$(realpath -m ~/.local/share/icons)"
export XCURSOR_PATH

eval "$(luarocks path)"

unset appendenv prependenv appendpath prependpath

export XCURSOR_THEME="Vimix-cursors"

# Load profiles from /etc/profile.d
if test -d /etc/profile.d/; then
	for profile in /etc/profile.d/*.sh; do
		test -r "$profile" && . "$profile"
	done
	unset profile
fi

# Source global bash config
if test "$PS1" && test "$BASH" && test -z ${POSIXLY_CORRECT+x} && test -r /etc/bash.bashrc; then
	. /etc/bash.bashrc
fi

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

eval `dircolors "$HOME/.dir_colors"`

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s` 1>/dev/null
fi

if [ -e "$HOME/.profile_extra" ]; then
  source "$HOME/.profile_extra"
fi

export DOT_PROFILE_LOADED=1
