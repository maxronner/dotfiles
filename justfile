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

# Lint package manifest placement and entries
lint:
    bash install/lint-packages.sh

# Test local tool modules and theme adapters
test-tools:
    python3 tools/thememanager/tests/test_thememanager.py
    bash local/dot-local/lib/theme/theme-apply-all.test.sh
