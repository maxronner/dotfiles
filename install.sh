#!/usr/bin/env bash

# ---- Dotfiles ----

# -- Create symlinks --



# ---- Setup keychain ----

# -- eza --
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list


# ---- Install tools ----
sudo apt update
sudo apt install -y nala
sudo nala install -y tmux fzf bat tldr thefuck eza xclip


# ---- Program specific setup ----

# -- bat --

# Create the ~/.local/bin directory if it doesn't already exist
mkdir -p ~/.local/bin

# Remove the existing symlink (if any) before creating a new one
if [ -L ~/.local/bin/bat ]; then
    rm ~/.local/bin/bat
    echo "Removed existing symlink for bat."
fi

# Create a symlink for bat to ~/.local/bin pointing to /usr/bin/batcat
ln -s /usr/bin/batcat ~/.local/bin/bat
echo "Created symlink for bat."


# -- tldr --

# Update tldr cache
tldr --update

