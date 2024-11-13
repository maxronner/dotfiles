#!/usr/bin/env bash

# ---- Dotfiles ----

# --- Create symlinks ---

# Define the source directory for dotfiles
dotfiles_dir=~/dotfiles

# Ensure dotfiles_dir exists
if [ ! -d "$dotfiles_dir" ]; then
    echo "Error: $dotfiles_dir directory not found!"
    exit 1
fi

# Enable dotglob to include hidden files (files starting with a dot)
shopt -s dotglob

echo "Found dotfiles directory: $dotfiles_dir"

# Iterate over all files in the dotfiles directory, including hidden files
for file in "$dotfiles_dir"/*; do
    # Extract the filename from the full path
    filename=$(basename "$file")

    # Debug: Show the file being processed
    echo "Processing file: $filename"

    # Skip the script file itself (install.sh)
    if [ "$filename" == "install.sh" ]; then
        echo "Skipping install.sh"
        continue
    fi

    # Check if a symlink already exists and remove it if present
    if [ -L ~/"$filename" ]; then
        echo "Removing existing symlink: ~/$filename"
        rm ~/"$filename"
    fi

    # Check if a regular file or directory exists and back it up if present
    if [ -e ~/"$filename" ] && [ ! -e ~/"$filename.bak" ]; then
        echo "Backing up existing file: ~/$filename to ~/$filename.bak"
        mv ~/"$filename" ~/"$filename.bak"
    fi

    # Create the symlink with the full path
    echo "Creating symlink: ln -s $file ~/$filename"
    ln -s "$file" ~/"$filename"
    echo "Created symlink for $filename -> $file"
done

# Disable dotglob to revert back to the default behavior
shopt -u dotglob

source ~/.bashrc

# ---- Setup keychain ----

# --- eza ---
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list


# ---- Install tools ----
sudo apt update
sudo apt install -y nala
sudo nala install -y tmux fzf bat tldr thefuck eza xclip

# --- Delta (git diff) ---

# -- Fetch the latest release tag from GitHub --
latest_version=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# -- Normalize the format to remove 'v' prefix if present --
latest_version=${latest_version#v}

# -- Get the currently installed version, removing any unwanted output formatting --
installed_version=$(delta --version 2>/dev/null | awk '{print $2}')

# -- Check if the latest version is already installed --
if [ "$installed_version" == "$latest_version" ]; then
    echo "Delta is already up to date (version $installed_version)."
    exit 0
fi

# -- Construct the download URL for the .deb file (assuming amd64) --
deb_url="https://github.com/dandavison/delta/releases/download/${latest_version}/git-delta_${latest_version}_amd64.deb"

# -- Download the .deb file --
wget "$deb_url" -O git-delta_latest_amd64.deb

# -- Install the .deb file --
sudo dpkg -i git-delta_latest_amd64.deb

# -- Clean up the .deb file after installation --
rm git-delta_latest_amd64.deb

# ---- Program specific setup ----

# --- bat ---

# -- Create the ~/.local/bin directory if it doesn't already exist --
mkdir -p ~/.local/bin

# -- Remove the existing symlink (if any) before creating a new one --
if [ -L ~/.local/bin/bat ]; then
    rm ~/.local/bin/bat
    echo "Removed existing symlink for bat."
fi

# -- Create a symlink for bat to ~/.local/bin pointing to /usr/bin/batcat --
ln -s /usr/bin/batcat ~/.local/bin/bat
echo "Created symlink for bat."

# --- tmux ---

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# --- tldr ---

# -- Update tldr cache --
tldr --update

echo "Install completed. Don't forget to install a nerd-font for icon support!"
