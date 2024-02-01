#!/usr/bin/bash

# Sugar function for creating a new worktree for a given branch. Will create
# the branch if it doesn't exist. Otherwise the new worktree is checked out to
# the existing branch.
function git_wt() {
    local common_dir="$(git rev-parse --git-common-dir)"
    local tree_path="$common_dir/trees/$1"

    if git rev-parse --verify "$1" > /dev/null; then
        # Branch exists
        if [ ! -d "$tree_path" ]; then
            git worktree add "$tree_path" "$1"
        else
            echo "Worktree already exists!"
        fi
    else
        git worktree add "$tree_path" -b "$1"
    fi
}

# Fetch a PR and check it out in the working tree.
function git_pr_checkout() {
    pr-fetch "$1" && git checkout "pr/$1";
}

# Fetch, and create a new worktree for a PR.
function git_pr_wt() {
    local common_dir="$(git rev-parse --path-format=absolute --git-common-dir)";
    local bname="pr/$1";
    pr-fetch "$1" && git worktree add "$common_dir/trees/$bname" "$bname";
}
