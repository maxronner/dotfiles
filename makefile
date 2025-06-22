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
	syncthing \
	tealdeer \
	tgpt \
	tmux \
	ttf-hack-nerd \
	unzip \
	yazi \
	zig \
	zk \
	zoxide \
	zsh \

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
	@echo "Installing TPM (tmux package manager)..."
	@if [ ! -d ~/.config/tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.config/tmux/plugins/tpm; \
	fi

# Install Desktop Environment packages
install_desktop:
	@echo "Installing Desktop Environment packages..."
	$(PACKAGE_MANAGER) $(DESKTOP_PKGS)

	@echo "Overriding sway .desktop file..."
	@sudo sed -i -E "s|^([[:space:]]*Exec=)(sway)(.*)$$|\\1sh -c 'export XDG_CURRENT_DESKTOP=sway \\&\\& \\2\\3'|" /usr/share/wayland-sessions/sway.desktop

# Install AUR packages
install_aur:
	@if ! command -v yay > /dev/null; then \
		echo "yay not found. Installing yay..."; \
		git clone https://aur.archlinux.org/yay.git $(HOME)/yay && cd $(HOME)/yay && makepkg -s --noconfirm; \
		sudo pacman -U --noconfirm --needed $$(find $(HOME)/yay -name "*.pkg.tar.zst" | head -n 1); \
		rm -rf $(HOME)/yay; \
	fi
	@echo "Downloading AUR packages..."
	$(AUR_HELPER) $(AUR_PKGS)

stow_dotfiles:
	@echo "Stowing dotfiles from $(STOW_DIR) to $(HOME)..."
	@for dir in $(STOW_DIR)/*; do \
		if [ -d $$dir ]; then \
			echo "Stowing $$(basename $$dir)..."; \
			stow --dotfiles -d $(STOW_DIR) -t $(HOME) $$(basename $$dir); \
		fi \
	done

unstow_dotfiles:
	@echo "Unstowing dotfiles from $(HOME)..."
	@for dir in $(STOW_DIR)/*; do \
		if [ -d $$dir ]; then \
			echo "Unstowing $$(basename $$dir)..."; \
			stow --dotfiles --delete -d $(STOW_DIR) -t $(HOME) $$(basename $$dir); \
		fi \
	done

enable_systemd_services:
	@echo "Enabling generic systemd services..."
	@sudo systemctl enable --now $(SYSTEM_SERVICES) || exit 1

	@echo "Enabling specific user services..."
	@systemctl --user enable --now $(USER_SERVICES) || exit 1

	@echo "Enabling all user services in $(HOME)/.config/systemd/user..."
	@systemctl --user enable --now $$(find $(HOME)/.config/systemd/user -maxdepth 1 -name "*.service") || exit 1

setup_timesyncd:
	@echo "Setting up timesyncd..."
	@sudo mkdir -p /etc/systemd/timesyncd.conf.d
	@echo "[Time]" | sudo tee /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
	@echo "NTP=$(NTP_SERVERS)" | sudo tee -a /etc/systemd/timesyncd.conf.d/local.conf > /dev/null
	@sudo timedatectl set-ntp false
	@sudo timedatectl set-ntp true
	@sudo systemctl restart systemd-timesyncd
	@sudo timedatectl set-timezone $(TIMEZONE)

setup_ly:
	@echo "Configuring ly..."; \
	LY_CONFIG=/etc/ly/config.ini; \
	sudo sed -i 's/^[[:space:]]*animation[[:space:]]*=.*/animation = matrix/' $$LY_CONFIG; \
	sudo sed -i 's/^[[:space:]]*clock[[:space:]]*=.*/clock = %c/' $$LY_CONFIG; \
	sudo sed -i 's/^[[:space:]]*vi_mode[[:space:]]*=.*/vi_mode = true/' $$LY_CONFIG; \
	echo "Overriding ly service..."; \
	LY_OVERRIDE_DIR=/etc/systemd/system/ly.service.d; \
	LY_OVERRIDE_FILE=$$LY_OVERRIDE_DIR/override.conf; \
	sudo mkdir -p $$LY_OVERRIDE_DIR; \
	echo "[Service]" | sudo tee $$LY_OVERRIDE_FILE > /dev/null; \
	echo "StandardOutput=null" | sudo tee -a $$LY_OVERRIDE_FILE > /dev/null; \
	echo "StandardError=null" | sudo tee -a $$LY_OVERRIDE_FILE > /dev/null; \
	sudo systemctl daemon-reexec; \
	echo "Enabling ly service..."; \
	sudo systemctl enable --now ly.service; \
	sudo systemctl disable --now getty@tty2.service

setup_device_specifics:
ifeq ($(strip $(env)),)
	@echo "env is not set, nothing to do."
else ifeq ($(env),workstation)
	@echo "Installing workstation specific packages..."
	$(PACKAGE_MANAGER) $(WORKSPACE_PKGS)

	@echo "Disabling USB wakeup for microphone..."
	echo "disabled" | sudo tee /sys/bus/usb/devices/5-2/power/wakeup

	$(MAKE) setup_nvidia
else ifeq ($(env),laptop)
	@echo "Installing laptop specific packages..."
	$(PACKAGE_MANAGER) $(LAPTOP_PKGS)

	@echo "Setting up dhcpcd..."
	@sudo systemctl enable --now dhcpcd.service
else
	@echo "Unknown env: $(env)"
endif
	@echo "Installing $(env) specific dotfiles..."
	@stow --dotfiles -d $(BASE_DIR)devices -t $(HOME) $(env)

setup_nvidia:
	@echo "Configuring nvidia..."
	$(PACKAGE_MANAGER) $$(./build/nvidia-driver-picker.sh)
	@sudo sed -i "/^[[:space:]]*Exec=.*sway/ {/--unsupported-gpu/! s|\\(sway\\)\\([[:space:]]*['\"]\\)|\\1 --unsupported-gpu\\2|}" /usr/share/wayland-sessions/sway.desktop
