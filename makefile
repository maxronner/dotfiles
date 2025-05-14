PACKAGE_MANAGER := sudo pacman -Syu --needed --noconfirm
AUR_HELPER := yay --needed --noconfirm --sudoflags "-S"

# Variables for directories
USERNAME := $(shell whoami)
HOME := /home/$(USERNAME)
BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
STOW_DIR := $(BASE_DIR)config

# Pacman packages: CLI/Environment Tools
CLI_PKGS := \
	7zip \
	base-devel \
	bash-completion \
	bat \
	btop \
	dhcpcd \
	eza \
	fastfetch \
	fd \
	fzf \
	gammastep \
	git \
	git-delta \
	go \
	htop \
	inotify-tools \
	iwd \
	jq \
	libnotify \
	man-db \
	nano \
	neomutt \
	neovim \
	noto-fonts \
	noto-fonts-emoji \
	npm \
	nss-mdns \
	openntpd \
	openssh \
	pacman-contrib \
	pass \
	pass-otp \
	passff-host \
	pipewire-pulse \
	ripgrep \
	rsync \
	starship \
	stow \
	syncthing \
	tealdeer \
	tgpt \
	thefuck \
	tmux \
	unzip \
	yazi \
	zig \
	zk \
	zoxide \
	zsh

# Pacman packages: Desktop Environment
DESKTOP_PKGS := \
	autotiling \
	chromium \
	firefox \
	flatpak \
	foot \
	gimp \
	gnome-themes-extra \
	mako \
	pavucontrol \
	sway \
	swaybg \
	swayidle \
	swaylock \
	ttf-hack-nerd \
	waybar \
	wl-clipboard \
	wofi \
	xdg-desktop-portal-gtk \
	xdg-desktop-portal-wlr

# AUR packages
AUR_PKGS := \
	rose-pine-cursor \
	zen-browser-bin

WORKSPACE_PKGS := \
	steam \
	nvidia-open

LAPTOP_PKGS := \
	kmonad \
	iwd \
	bluez \
	bluez-utils

DEPS := \
	install_cli \
	install_desktop \
	install_aur \
	install_optional \
	stow_dotfiles

.PHONY: all install_cli install_desktop install_aur stow_dotfiles

# Default target
all: $(DEPS)
	@echo "All packages installed and dotfiles symlinked successfully!"

# Install CLI/Environment tools
install_cli:
	@echo "Installing CLI/Environment packages..."
	$(PACKAGE_MANAGER) $(CLI_PKGS)
	@echo "Installing TPM (tmux package manager)..."
	@if [ ! -d ~/.config/tmux/plugins/tpm ]; then \
		su - $(USERNAME) -c "git clone https://github.com/tmux-plugins/tpm $(HOME)/.config/tmux/plugins/tpm"; \
	fi

# Install Desktop Environment packages
install_desktop:
	@echo "Installing Desktop Environment packages..."
	$(PACKAGE_MANAGER) $(DESKTOP_PKGS)

# Install AUR packages
install_aur:
	@if ! command -v yay > /dev/null; then \
		echo "yay not found. Installing yay..."; \
		[ -d /tmp/yay ] && rm -rf /tmp/yay; \
		su - $(USERNAME) -c "git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -s --noconfirm"; \
		pacman -U --noconfirm --needed $(find /tmp/yay -name "*.pkg.tar.zst" | head -n 1); \
		rm -rf /tmp/yay; \
	fi
	@echo "Downloading AUR packages..."
	$(AUR_HELPER) $(AUR_PKGS)

install_optional:
ifeq ($(strip $(env)),)
	@echo "env is not set, nothing to do."
endif
ifeq ($(env), workstation)
	@echo "Installing workstation specific packages..."
	$(PACKAGE_MANAGER) $(WORKSPACE_PKGS)
	@echo "Disabling USB wakeup for microphone..."
	echo "disabled" | sudo tee /sys/bus/usb/devices/5-2/power/wakeup
	@echo "Installing workstation specific dotfiles..."
	@stow --dotfiles -d $(BASE_DIR)devices -t $(HOME) workstation
endif
ifeq ($(env), laptop)
	@echo "Installing laptop specific packages..."
	$(PACKAGE_MANAGER) $(LAPTOP_PKGS)
	@echo "Installing laptop specific dotfiles..."
	@stow --dotfiles -d $(BASE_DIR)devices -t $(HOME) laptop
endif

stow_dotfiles:
	@echo "Stowing dotfiles from $(STOW_DIR) to $(HOME)..."
	@for dir in $(STOW_DIR)/*; do \
		if [ -d $$dir ]; then \
			echo "Stowing $$(basename $$dir)..."; \
			stow --dotfiles -d $(STOW_DIR) -t $(HOME) $$(basename $$dir); \
		fi \
	done

