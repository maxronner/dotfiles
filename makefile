USERNAME := $(shell whoami)
HOME := /home/$(USERNAME)
BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

DEPS := \
	install_cli \
	install_desktop \
	install_aur \
	setup_device_specifics \
	stow_dotfiles \
	stow_scripts \
	setup_services \
	set_theme \
	setup_password_store

.PHONY: all $(DEPS) unstow_dotfiles

all: $(DEPS)
	@echo "All packages installed and dotfiles symlinked successfully!"

install_cli:
	@bash install/10-install-cli.sh
	@bash install/11-install-tpm.sh

install_desktop:
	@bash install/20-install-desktop.sh
	@bash install/22-setup-ly.sh
	@bash install/23-nvidia-driver-picker.sh

install_aur:
	@bash install/30-install-yay.sh
	@bash install/31-install-aur.sh

setup_services:
	@bash install/40-enable-systemd-services.sh
	@bash install/41-setup-timesyncd.sh

stow_dotfiles:
	@bash install/50-stow-dotfiles.sh
	@bash install/51-stow-device-dotfiles.sh $(env)

stow_scripts:
	@echo "Stowing scripts from $(BASE_DIR)scripts to $(HOME)/.local/bin..."
	@stow -t $(HOME)/.local/bin scripts

setup_device_specifics:
	@if [ -z "$(env)" ]; then \
		echo "env is not set, nothing to do."; \
	elif [ "$(env)" = "workstation" ]; then \
		bash install/specifics/setup-workstation.sh; \
	elif [ "$(env)" = "laptop" ]; then \
		bash install/specifics/setup-laptop.sh; \
	else \
		echo "Unknown env: $(env)"; \
	fi
	@bash install/60-configure-sway-desktop.sh

set_theme:
	@python3 scripts/thememanager set rose-pine-moon

setup_password_store:
	@bash install/70-setup-pass-store-chmod.sh

unstow_dotfiles:
	@bash install/extras/unstow-dotfiles.sh

