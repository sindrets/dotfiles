#!/usr/bin/bash

function git_wt() {
    local common_dir="$(git rev-parse --git-common-dir)"
    local tree_path="$common_dir/trees/$1"

    if [ $(git rev-parse --verify "$1" > /dev/null) ]; then
        if [ ! -d "$tree_path" ]; then
            git worktree add "$tree_path" "$1"
        else
            echo "Worktree already exists!"
        fi
    else
        git worktree add "$tree_path" -b "$1"
    fi
}
