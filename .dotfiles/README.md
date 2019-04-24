# Installing the dotfiles

* Clone your dotfiles into a bare repository in a "dot" folder of your $HOME:

```sh
git clone --bare "https://github.com/sindrets/dotfiles.git" $HOME/.dotfiles
```

* Define this alias in your current shell, and disable git status of untracked files:

```sh
# the alias is defined in the .bashrc, so it will always be available once you've synced that
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
```
> NOTE: the following will overwrite any conflicting dotfiles on your local machine. Back up your files now if you care about them!

* Hard reset your repository to the master branch

```sh
dotfiles reset --hard origin/master
```

### Adding new dotfiles
```sh
dotfiles add file
# when all files are added; push to the repo:
dotfiles commit
dotfiles push
```

### Updating all modified tracked files
```sh
dotfiles commit -a
dotfiles push
```

