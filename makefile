PACKAGE_MANAGER := sudo pacman -Syu --needed --noconfirm
AUR_HELPER := yay --needed --noconfirm --sudoflags "-S"

TIMEZONE := Europe/Stockholm
NTP_SERVERS := 0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org

# Variables for directories
USERNAME := $(shell whoami)
HOME := /home/$(USERNAME)
BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
STOW_DIR := $(BASE_DIR)config

# Pacman packages: CLI/Environment Tools
CLI_PKGS := \
	7zip \
	astroterm \
	atac \
	base-devel \
	bash-completion \
	bat \
	bluetui \
	btop \
	chafa \
	duf \
	dust \
	eza \
	fastfetch \
	fd \
	fzf \
	gammastep \
	ghostty \
	git \
	git-delta \
	go \
	htop \
	inotify-tools \
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
	openssh \
	pacman-contrib \
	pass \
	pass-otp \
	passff-host \
	pipewire-pulse \
	pulsemixer \
	ripgrep \
	rsync \
	starship \
	stow \
	sqlite \
	syncthing \
	task \
	taskwarrior-tui \
	tealdeer \
	tgpt \
	tmux \
	ttf-hack-nerd \
	unzip \
	zig \
	zk \
	zoxide \
	zsh \
	zsh-autosuggestions \
	zsh-history-substring-search \
	zsh-syntax-highlighting \

# Pacman packages: Desktop Environment
DESKTOP_PKGS := \
	autotiling \
	blueman \
	chromium \
	cmatrix \
	firefox \
	flameshot \
	flatpak \
	foot \
	gimp \
	gnome-themes-extra \
	ly \
	mako \
	pavucontrol \
	sway \
	swaybg \
	swayidle \
	swaylock \
	ttf-jetbrains-mono-nerd \
	waybar \
	wl-clipboard \
	xdg-desktop-portal-gtk \
	xdg-desktop-portal-wlr

# AUR packages
AUR_PKGS := \
	tofi \
	rose-pine-cursor \
	yt-x \
	zen-browser-bin

WORKSPACE_PKGS := \
	steam \

LAPTOP_PKGS := \
	dhcpcd \
	kmonad \
	iwd \
	bluez \
	bluez-utils

SYSTEM_SERVICES := \
	avahi-daemon.service \
	bluetooth.service \
	sshd.service \
	systemd-resolved.service \
	systemd-timesyncd.service

USER_SERVICES := \
	mako.service \
	syncthing.service

DEPS := \
	install_cli \
	install_desktop \
	install_aur \
	setup_device_specifics \
	stow_dotfiles \
	stow_scripts \
	enable_systemd_services \
	setup_timesyncd \
	setup_ly

.PHONY: install_cli install_desktop install_aur setup_ly setup_nvidia

# Default target
all: $(DEPS)
	@echo "All packages installed and dotfiles symlinked successfully!"

# Install CLI/Environment tools
install_cli:
	@echo "Installing CLI/Environment packages..."
	$(PACKAGE_MANAGER) $(CLI_PKGS)
	@bash build/install-tpm.sh

# Install Desktop Environment packages
install_desktop:
	@echo "Installing Desktop Environment packages..."
	$(PACKAGE_MANAGER) $(DESKTOP_PKGS)
	@bash build/configure-sway-desktop.sh

# Install AUR packages
install_aur:
	@bash build/install-yay.sh
	@echo "Downloading AUR packages..."
	$(AUR_HELPER) $(AUR_PKGS)

stow_dotfiles:
	@echo "Stowing dotfiles from $(STOW_DIR) to $(HOME)..."
	@bash build/stow-dotfiles.sh
ifeq ($(env),)
	@echo "env is not set, nothing to do."
else
	@echo "Installing $(env) specific dotfiles..."
	@stow --dotfiles -d $(BASE_DIR)devices -t $(HOME) $(env)
endif

unstow_dotfiles:
	@echo "Unstowing dotfiles from $(HOME)..."
	@bash build/unstow-dotfiles.sh
ifeq ($(env),)
	@echo "env is not set, nothing to do."
else
	@echo "Unstowing $(env) specific dotfiles..."
	@stow --dotfiles --delete -d $(BASE_DIR)devices -t $(HOME) $(env)
endif

stow_scripts:
	@echo "Stowing scripts from $(BASE_DIR)scripts to $(HOME)/.local/bin..."
	@stow -t $(HOME)/.local/bin scripts

enable_systemd_services:
	@echo "Enabling generic systemd services..."
	@bash build/enable-systemd-services.sh "$(SYSTEM_SERVICES)" "$(USER_SERVICES)"

setup_timesyncd:
	@echo "Setting up timesyncd..."
	@bash build/setup-timesyncd.sh "$(TIMEZONE)" "$(NTP_SERVERS)"

setup_ly:
	@echo "Configuring ly..."
	@bash build/setup-ly.sh

setup_device_specifics:
ifeq ($(strip $(env)),)
	@echo "env is not set, nothing to do."
else ifeq ($(env),workstation)
	@echo "Installing workstation specific packages..."
	$(PACKAGE_MANAGER) $(WORKSPACE_PKGS)
	$(MAKE) setup_nvidia
else ifeq ($(env),laptop)
	@echo "Installing laptop specific packages..."
	$(PACKAGE_MANAGER) $(LAPTOP_PKGS)
	@bash build/setup-laptop.sh
else
	@echo "Unknown env: $(env)"
endif

setup_nvidia:
	@echo "Configuring nvidia..."
	$(PACKAGE_MANAGER) $$(./build/nvidia-driver-picker.sh)
	@sudo sed -i "/^[[:space:]]*Exec=.*sway/ {/--unsupported-gpu/! s|\\(sway\\)\\([[:space:]]*['\"]\\)|\\1 --unsupported-gpu\\2|}" /usr/share/wayland-sessions/sway.desktop
