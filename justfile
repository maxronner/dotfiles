dots_dir := justfile_directory()

# Full install: base + detected WM repos
install profile:
    just install-base {{profile}}
    @for wm in hyprland sway; do \
        if [ -d "{{dots_dir}}/$wm" ]; then \
            echo "[INFO] Found $wm repo, installing layer 2..."; \
            bash "{{dots_dir}}/$wm/install.sh" {{profile}}; \
        fi; \
    done

# Install shared base only (layer 1)
install-base profile:
    bash install/install.sh all {{profile}}

# Install system packages only
system profile:
    bash install/install.sh system {{profile}}

# Install user dotfiles only
user profile:
    bash install/install.sh user {{profile}}

# Install hyprland layer 2
hyprland profile:
    bash "{{dots_dir}}/hyprland/install.sh" {{profile}}

# Install sway layer 2
sway profile:
    bash "{{dots_dir}}/sway/install.sh" {{profile}}

# Remove all managed symlinks
unlink profile:
    bash install/unlink.sh {{profile}}

# Run extras (nvim, dev, ly)
extra name='':
    #!/usr/bin/env bash
    if [ -z "{{name}}" ]; then
        echo "Available extras:"
        for f in install/extras/*.sh; do
            basename "$f" .sh
        done
        exit 0
    fi
    if [ ! -f "install/extras/{{name}}.sh" ]; then
        echo "Unknown extra: {{name}}"
        echo ""
        echo "Available extras:"
        for f in install/extras/*.sh; do
            basename "$f" .sh
        done
        exit 1
    fi
    bash "install/extras/{{name}}.sh"

# Lint: check all app/system/device dirs have pkg.txt
lint:
    @missing=0; \
    for dir in "{{justfile_directory()}}"/apps/*/ "{{justfile_directory()}}"/system/*/ "{{justfile_directory()}}"/devices/*/; do \
        if [ ! -f "$dir/pkg.txt" ]; then \
            echo "MISSING pkg.txt: $dir"; \
            missing=1; \
        fi; \
    done; \
    [ $missing -eq 0 ] && echo "All packages have pkg.txt" || exit 1
