PACKAGE_MANAGER := pacman -Syu --needed --noconfirm
AUR_HELPER := yay --needed --noconfirm --sudoflags "-S"

USERNAME := max

# Variables for directories
TMP_DIR := /tmp/sysconfig
HOME := /home/max
STOW_DIR := $(HOME)/dotfiles/xdg_config

# Pacman packages: CLI/Environment Tools
CLI_PKGS := \
	base-devel \
	bat \
	btop \
	dhcpcd \
	eza \
	fd \
	fastfetch \
	fzf \
	gammastep \
	git \
	git-delta \
	go \
	inotify-tools \
	iwd \
	jq \
	libnotify \
	mako \
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
	pipewire-pulse \
	ripgrep \
	rsync \
	starship \
	stow \
	sudo \
	syncthing \
	tealdeer \
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
	bemenu \
	bluez \
	firefox \
	flatpak \
	foot \
	gnome-themes-extra \
	pavucontrol \
	sway \
	swaybg \
	swayidle \
	swaylock \
	ttf-hack-nerd \
	wl-clipboard \
	xdg-desktop-portal-gtk \
	xdg-desktop-portal-wlr

# AUR packages
AUR_PKGS := \
	rose-pine-cursor \
	zen-browser-bin

DEPS := \
	install_cli \
	install_desktop \
	create_user \
	install_aur \
	install_optional \
	stow_dotfiles \
	clean

.PHONY: all install_cli install_desktop install_aur stow_dotfiles create_user clean

# Default target
all: $(DEPS)
	@echo "All packages installed and dotfiles symlinked successfully!"

create_user:
	@echo "Checking if user $(USERNAME) exists..."
	@if id $(USERNAME) &>/dev/null; then \
		echo "User $(USERNAME) already exists. Skipping user creation."; \
	else \
		echo "Creating user $(USERNAME)..."; \
		useradd -m -s /bin/bash $(USERNAME); \
		echo "User $(USERNAME) created."; \
	fi
	@echo "Setting up sudo"
	@if ! grep "%sudo ALL=(ALL:ALL) ALL" /etc/sudoers > /dev/null 2>&1; then \
	    echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers; \
	fi

	@if ! grep -q '^sudo:' /etc/group; then \
	    groupadd sudo; \
	fi

	@echo "Checking if /home/$(USERNAME) exists..."
	@if [ ! -d /home/$(USERNAME) ]; then \
		echo "Creating /home/$(USERNAME) directory..."; \
		mkdir -p /home/$(USERNAME); \
		chown $(USERNAME):$(USERNAME) /home/$(USERNAME); \
		echo "/home/$(USERNAME) directory created."; \
	else \
		echo "/home/$(USERNAME) directory already exists. Skipping."; \
	fi

	@echo "Adding $(USERNAME) to sudo group if not already added..."
	@if ! groups $(USERNAME) | grep -q '\bsudo\b'; then \
		usermod -aG sudo $(USERNAME); \
		echo "$(USERNAME) added to sudo group."; \
	else \
		echo "$(USERNAME) is already a member of the sudo group."; \
	fi

# Install CLI/Environment tools
install_cli:
	@echo "Installing CLI/Environment packages..."
	$(PACKAGE_MANAGER) $(CLI_PKGS)

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
	su - $(USERNAME) -c "$(AUR_HELPER) $(AUR_PKGS)"

install_optional:
ifeq ($(strip $(env)),)
	@echo "env is not set, nothing to do."
else
	su - $(USERNAME) -c "stow -d $(HOME)/dotfiles/devices -t $(HOME) --no-folding $(env)"
endif
ifeq ($(env), workstation)
	@echo "Building Tabby for workstation..."
	# TODO: build tabby
endif
ifeq ($(env), laptop)
	@echo "Nothing to do for laptop."
endif

stow_dotfiles:
	@echo "Stowing dotfiles from $(STOW_DIR) to $(HOME)..."
	@for dir in $(STOW_DIR)/*; do \
		if [ -d $$dir ]; then \
			su - $(USERNAME) -c "stow -d $(STOW_DIR) -t $(HOME) $$(basename $$dir)"; \
		fi \
	done

clean:
	@echo "Cleaning up build files..."
	@rm -rf $(TMP_DIR)

