#!/usr/bin/bash

# Sugar function for creating a new worktree for a given branch. Will create
# the branch if it doesn't exist. Otherwise the new worktree is checked out to
# the existing branch.
function git_wt() {
    set -e
    local common_dir="$(git rev-parse --git-common-dir)"
    local tree_path="$common_dir/trees/$1"

    if git rev-parse --verify "$1" &> /dev/null; then
        # Branch exists
        if [ ! -d "$tree_path" ]; then
            git worktree add "$tree_path" "$1"
        else
            echo "Worktree already exists!"
        fi
    else
        git worktree add "$tree_path" -b "$1" --no-checkout
        git branch -u origin/"$1" "$1"
        cd "$tree_path"
        env --unset=GIT_DIR git reset --hard @{upstream}
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

function git_clone_bare() {
    set -e
    git clone --bare $@

    if [ ! -z "$2" ]; then
        local repo_dir="$2";
    else
        local repo_dir="$(echo "$1" | awk -F/ '{print $NF}')"
    fi

    cd "$repo_dir"
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git remote update
    git remote set-head -a origin

    local main_branch="$(\
        git rev-parse --symbolic-full-name origin/HEAD \
        | awk -F'/remotes/origin/' '{print $NF}' \
    )"

    git wt "$main_branch"
}

function git_changed_files() {
    set -e

    if [ ! -z "$1" ]; then
        base_rev="$1"
    else
        base_rev="$(git merge-base origin/HEAD HEAD || echo "HEAD")"
    fi

    changed_files="$(git diff --name-only $base_rev)"
    untracked_files="$(git ls-files --others --exclude-standard)"

    for file in "$changed_files $untracked_files"; do
        echo "$file"
    done
}
