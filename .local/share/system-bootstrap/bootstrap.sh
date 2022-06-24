#!/usr/bin/bash

# ======================================
# Bootstrapping script for a new system.
# ======================================
#
# --- WIP ---

set -euo pipefail

script_home="$(realpath -m "$0/..")"
# Working directory
wd="/tmp/system-bootstrap"

# Set up working directory
rm -rf "$wd"
mkdir -p "$wd"
cd "$wd"

# Utils

reset='\e[0m'
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'

function success() {
  echo -e "${green}✓ $1${reset}"
}

function info() {
  echo -e "\n${cyan}INFO: $1${reset}"
}

function warn() {
  echo -e "\n${yellow}WARN: $1${reset}" >&2
}

function err() {
  echo -e "\n${red}ERROR: $1${reset}" >&2
}

function fatal() {
  echo -e "\n${red}FATAL: $1${reset}" >&2
  exit 1
}

function in_array() {
  local i
  for i in "${@:2}"; do
    [[ $1 = "$i" ]] && return 0
  done
  return 1
}

args=($@)

function usage() {
  cat <<EOF
usage: ${0##*/} [options] [tasks]

  If no tasks are specified, then all tasks will be ran.

  Options:
    -h, --help  Print help and exit.

  Tasks:
    yay         Install yay.
    deps        Install system config dependencies.
    ssh         Set up and configure ssh.
    dotfiles    Install dotfiles.

EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then
  usage
  exit $(( $# ? 0 : 1 ))
fi

# Install yay
function install_yay() {
  if [ $(type -P yay) ]; then
    info "Yay already installed!"
    return
  fi

  info "Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git "$wd/yay"
  (
    cd "$wd/yay"
    makepkg -si
  )
}

# Install config system dependencies
function install_dependencies() {
  info "Installing config system dependencies..."

  local pkg_list="$script_home/pkg-dependencies.txt"

  if [ ! -e "$pkg_list" ]; then
    curl -o "./pkg-dependencies.txt" 'https://raw.githubusercontent.com/sindrets/dotfiles/master/.local/share/system-bootstrap/pkg-dependencies.txt'
    pkg_list="./pkg-dependencies.txt"
  fi

  sudo true
  yay --sudoloop -S --needed --norebuild --noredownload --nocleanmenu --nodiffmenu --noremovemake - \
    < "$pkg_list"
}

function setup_ssh() {
  if [ -e "$HOME/.ssh/id_ed25519" ]; then
    info "SSH already set up!"
    return
  fi

  info "Setting up ssh..."
  ssh-keygen -t ed25519 -C "sindrets@gmail.com"
  if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s` 1>/dev/null
  fi
  info "Before continuing, add your new public key to github:"
  bat -P ~/.ssh/id_ed25519.pub
  xdg-open 'https://github.com/settings/ssh/new'
  read -sp "Press enter to continue..."
}

function install_dotfiles() {
  if [ -d "$HOME/.dotfiles" ]; then
    info "Dotfiles already installed!"
    return
  fi

  info "Installing dotfiles..."
  (
    function dotfiles() {
      /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" $@
    }
    git clone --bare "git@github.com:sindrets/dotfiles.git" "$HOME/.dotfiles"
    dotfiles config --local status.showUntrackedFiles no
    dotfiles config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    dotfiles remote update
    dotfiles branch -u origin/master
    dotfiles reset --hard
  )
}

function all() {
  install_yay
  install_dependencies
  setup_ssh
  install_dotfiles
  success "Bootstrap completed successfully!"
}

if [ ${#args[@]} -eq 0 ]; then
  all
else
  (in_array "yay" ${args[*]}) && install_yay
  (in_array "deps" ${args[*]}) && install_dependencies
  (in_array "ssh" ${args[*]}) && setup_ssh
  (in_array "dotfiles" ${args[*]}) && install_dotfiles
fi

# vim:ft=bash
