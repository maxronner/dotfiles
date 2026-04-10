#!/usr/bin/env sh

if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

if command -v eza >/dev/null 2>&1; then
  alias lt='eza --tree --level=5'
  alias ll='eza --long --all --all --icons --git --mounts --group'
  alias ls='eza --no-permissions --no-user --no-time --no-filesize --icons=always'
  alias l='eza --no-permissions --no-user --no-time --no-filesize --icons=always --long'
fi

if command -v bat >/dev/null 2>&1; then
  alias bat='bat --theme="ansi"'
  alias cat='bat'
fi

alias reboot='systemctl reboot'
alias sc='systemctl --user'
alias ssc='sudo systemctl'
alias mkdir='mkdir -p'

alias bd='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias conf="cd $HOME/.config/"

alias zi='zoxide query --interactive'
