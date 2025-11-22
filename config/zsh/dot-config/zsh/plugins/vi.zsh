#!/usr/bin/env zsh

bindkey -v

bindkey -M viins "${terminfo[khome]}" beginning-of-line
bindkey -M viins "${terminfo[kend]}"  end-of-line

bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
bindkey -M vicmd "${terminfo[kend]}"  end-of-line

bindkey -M vicmd '\e[1;5D' backward-word      # Ctrl + Left in normal mode
bindkey -M vicmd '\e[1;5C' forward-word       # Ctrl + Right in normal mode

bindkey -M viins '\e[1;5D' backward-word      # Ctrl + Left in insert mode
bindkey -M viins '\e[1;5C' forward-word       # Ctrl + Right in insert mode

bindkey -M vicmd '\e[3~' delete-char          # Delete in normal mode
bindkey -M viins '\e[3~' delete-char          # Delete in insert mode

bindkey -M viins '^H' backward-delete-word    # Ctrl+Backspace in insert mode
bindkey -M vicmd '^H' backward-delete-word    # Ctrl+Backspace in normal mode

bindkey -M viins '\e[3;5~' delete-word        # Ctrl+Delete in insert mode
bindkey -M vicmd '\e[3;5~' delete-word        # Ctrl+Delete in normal mode

bindkey -M viins '\e[1~' beginning-of-line    # Home in insert mode
bindkey -M vicmd '\e[1~' beginning-of-line    # Home in normal mode

bindkey -M viins '\e[4~' end-of-line          # End in insert mode
bindkey -M vicmd '\e[4~' end-of-line          # End in normal mode

bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^U' kill-whole-line

bindkey -M viins '^[.' insert-last-word
