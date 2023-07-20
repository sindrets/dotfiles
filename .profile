#/bin/sh

# Set our umask
umask 022

export XDG_CONFIG_HOME="$HOME/.config"
export VISUAL=nvim
export EDITOR=nvim
export BROWSER=/usr/bin/firefox-beta
export TERMINAL=kitty
export GREP_COLORS='ms=01;33:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
export npm_config_prefix="$HOME/.local"

# Append our default paths
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

appendpath '/usr/local/sbin'
appendpath '/usr/local/bin'
appendpath '/usr/bin'
appendpath "$HOME/.local/bin"
appendpath "$HOME/.local/sbin"
appendpath "$HOME/.config/scripts"
appendpath "$HOME/.emacs.d/bin"
appendpath "$(ruby -e 'puts Gem.user_dir')/bin"
unset appendpath

export PATH

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
