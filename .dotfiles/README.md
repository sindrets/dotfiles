# Installing the dotfiles

### Method 1: `git clone --bare`

* Clone the dotfiles into a bare git repository in your home directory:

```sh
git clone --bare "git@github.com:sindrets/dotfiles.git" "$HOME/.dotfiles"
```

* Define an alias to more easily interact with the dotfiles repo, and disable
  git status for untracked files:

```sh
# the alias is defined in .bashrc and .zshrc, so it will always be available once you've synced those
alias dotfiles="/usr/bin/git --git-dir='$HOME/.dotfiles/' --work-tree='$HOME'"
dotfiles config --local status.showUntrackedFiles no
dotfiles config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
dotfiles remote update
dotfiles branch -u origin/master
```
> NOTE: the following will overwrite any conflicting dotfiles on your local
> machine. Back up your files now if you care about them!

* Hard reset your repository to the master branch

```sh
dotfiles reset --hard
```

#### Adding new dotfiles

```sh
dotfiles add file
dotfiles commit
dotfiles push
```

### Method 2: `bootstrap.sh` *! WIP !*

This is a bootstrapping script for new arch linux installations that does a lot
more than just installing the dotfiles. It's meant to run after the base
installation is done.

```
bash <(curl https://raw.githubusercontent.com/sindrets/dotfiles/master/.local/share/system-bootstrap/bootstrap.sh)
```
