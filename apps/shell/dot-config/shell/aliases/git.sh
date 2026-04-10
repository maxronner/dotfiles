#!/usr/bin/env sh

alias g='git'

alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'

alias gb='git branch'
alias gbD='git branch --delete --force'
alias gba='git branch --all'
alias gbd='git branch --delete'

alias gc='git commit'
alias gca='git commit --amend'

alias gcb='git checkout -b'
alias gcB='git checkout -B'

alias gcl='git clone'
alias gco='git checkout'

alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias gd='git diff'
alias gi='git init'

alias gl='git log'
alias glg='git log --graph --decorate --all'
alias glo='git log --oneline --decorate --graph --all'

alias gm='git merge'
alias gmff='git merge --ff-only'

alias gp='git push'
alias gpf='git push --force-with-lease'

alias grb='git rebase'
alias grbm='git rebase main'
alias grbom='git fetch origin main && git rebase origin/main'

alias greo='git restore'
alias gree='git reset'

alias gs='git status --short'
alias gst='git stash'
alias gsw='git switch'
alias gu='git pull'

alias gw='git worktree'
alias gwl='git worktree list'

alias wtD='wt remove -D'
alias wtd='wt remove'
alias wts='wt switch'
alias wtsc='wt switch --create'
