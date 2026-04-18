#!/usr/bin/env zsh

autoload -Uz compinit

typeset -gi _lazy_completion_ready=0
typeset -g _lazy_completion_tab_widget=expand-or-complete

_lazy_completion_registrations_file=${0:A:h}/completion-registrations.zsh

_lazy_completion_register() {
    [ -f "$_lazy_completion_registrations_file" ] && \
        source "$_lazy_completion_registrations_file"
}

_lazy_completion_init() {
    (( _lazy_completion_ready )) && return 0

    compinit -C
    _lazy_completion_register
    bindkey '^[[Z' reverse-menu-complete
    _lazy_completion_ready=1
}

_lazy_completion_dispatch_tab() {
    _lazy_completion_init
    zle ${_lazy_completion_tab_widget}
}

_lazy_reverse_menu_complete() {
    _lazy_completion_init
    zle reverse-menu-complete
}

_lazy_completion_detect_tab_widget() {
    local binding

    binding=$(bindkey '^I')
    [[ $binding =~ 'undefined-key' ]] && return 0

    _lazy_completion_tab_widget=$binding[(s: :w)2]
}

_lazy_completion_detect_tab_widget

zle -N _lazy_completion_dispatch_tab
zle -N _lazy_reverse_menu_complete

bindkey '^I' _lazy_completion_dispatch_tab
bindkey '^[[Z' _lazy_reverse_menu_complete
