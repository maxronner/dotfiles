if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    ELECTRON_OZONE_PLATFORM_HINT=wayland
    exec sway --unsupported-gpu
fi
