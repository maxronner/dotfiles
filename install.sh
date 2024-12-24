#!/bin/bash

# Define the source directory for dotfiles
dotfiles_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Function to ensure dotfiles directory exists
check_dotfiles_dir() {
    if [ ! -d "$dotfiles_dir" ]; then
        echo "Error: $dotfiles_dir directory not found!"
        exit 1
    fi
}

# Function to create symlinks for dotfiles, recreating directory structures if needed
create_symlinks() {
    # Enable dotglob to include hidden files (files starting with a dot)
    shopt -s dotglob

    echo "Found dotfiles directory: $dotfiles_dir"

    echoed_git=0
    # Iterate over all files and directories in the dotfiles directory, including hidden files
    # We use find to handle nested directories as well
    find "$dotfiles_dir" -type f -not -path '*/.git/*' | while read -r item; do
        # Preserve relative path for nested structures
        relative_path="${item#$dotfiles_dir/}"
        target="$HOME/$relative_path"

        echo "Processing: $relative_path"

        # Skip specific items (install.sh, .git, etc.)
        if [ "$relative_path" == "install.sh" ] || [ "$relative_path" == ".git" ]; then
            echo "Skipping $relative_path"
            continue
        fi

        # Backup existing file if not already backed up
        if [ -e "$target" ] && [ ! -e "$target.bak" ]; then
            echo "Backing up existing file: $target to $target.bak"
            mv "$target" "$target.bak"
        fi

        # Create parent directories if they do not exist
        if [ ! -d "$(dirname "$target")" ]; then
            echo "Creating parent directories for $target"
            mkdir -p "$(dirname "$target")"
        fi

        # Create the symlink for the file
        echo "Creating symlink: ln -s $item $target"
        ln -sf "$item" "$target"
        echo "Created symlink for $relative_path -> $item"
    done

    # Disable dotglob to revert back to the default behavior
    shopt -u dotglob

    # Reload bashrc to apply changes
    if [ -f ~/.bashrc ]; then
        echo "Reloading .bashrc"
        source ~/.bashrc
    fi
}


# Function to setup eza repository key and add source list
setup_eza_repository() {
    # Check if keyring file already exists
    if [ -f /etc/apt/keyrings/gierens.gpg ]; then
        echo "Keyring already exists, skipping keyring setup."
    else
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "Keyring downloaded and saved as /etc/apt/keyrings/gierens.gpg"
    fi

    # Check if sources list entry already exists
    if grep -q "deb \[signed-by=/etc/apt/keyrings/gierens.gpg\] http://deb.gierens.de stable main" /etc/apt/sources.list.d/gierens.list; then
        echo "Eza repository already added to sources.list, skipping."
    else
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        echo "Eza repository added to /etc/apt/sources.list.d/gierens.list"
    fi

    # Set correct permissions for the keyring and sources list file
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
}


install_tools() {
    sudo apt update
    sudo apt install -y nala
    sudo nala install -y tmux fzf bat tldr thefuck eza xclip sway
}

install_delta() {
    # Fetch the latest release tag from GitHub
    latest_version=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

    # Remove 'v' prefix from version if present
    latest_version=${latest_version#v}

    # Get the currently installed version
    installed_version=$(delta --version 2>/dev/null | awk '{print $2}')

    # Check if the latest version is already installed
    if [ "$installed_version" == "$latest_version" ]; then
        echo "Delta is already up to date (version $installed_version)."
        exit 0
    fi

    # Construct the download URL for the .deb file (amd64)
    deb_url="https://github.com/dandavison/delta/releases/download/${latest_version}/git-delta_${latest_version}_amd64.deb"

    # Download and install the latest version of delta
    wget "$deb_url" -O git-delta_latest_amd64.deb
    sudo dpkg -i git-delta_latest_amd64.deb

    # Clean up the .deb file after installation
    rm git-delta_latest_amd64.deb
}

setup_bat() {
    mkdir -p ~/.local/bin

    # Remove existing symlink for bat if present
    if [ -L ~/.local/bin/bat ]; then
        rm ~/.local/bin/bat
        echo "Removed existing symlink for bat."
    fi

    # Create symlink for bat to ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
    echo "Created symlink for bat."
}

setup_tmux() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

setup_tldr() {
    tldr --update
}

# ---- Main Execution ----
# Call functions
check_dotfiles_dir
create_symlinks
setup_eza_repository
install_tools
install_delta
setup_bat
setup_tmux
setup_tldr

echo "Install completed. Don't forget to install a nerd-font for icon support!"
