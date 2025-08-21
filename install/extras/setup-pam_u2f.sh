#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
# Defines the directory and file for storing U2F key registrations.
U2F_DIR="$HOME/.config/Yubico"
U2F_KEYS_FILE="$U2F_DIR/u2f_keys"

# Defines the paths to the PAM configuration files that will be modified.
SYSTEM_AUTH_PAM_FILE="/etc/pam.d/system-auth"

# === Functions ===

# Creates a backup of a given file if one doesn't already exist.
#
# @param $1: The full path to the file to be backed up.
backup_file() {
    local file_path="$1"
    if [[ -f "$file_path" && ! -f "$file_path.bak" ]]; then
        printf "Backing up %s -> %s.bak\n" "$file_path" "$file_path"
        sudo cp "$file_path" "$file_path.bak"
    fi
}

# Inserts the pam_u2f module configuration into a PAM file if it's not already present.
#
# @param $1: The full path to the PAM file to be modified.
insert_pam_line() {
    local file_path="$1"
    # The line to be inserted. It makes U2F authentication a required step.
    # The "cue" option prompts the user with a message to touch their device.
    local line_to_insert="auth       required                    pam_u2f.so cue"
    # The configuration line will be inserted *after* this pattern.
    local anchor_pattern="^-auth.*pam_systemd_home\.so"

    # Check if the module is already configured to prevent duplicate entries.
    if ! grep -q "pam_u2f.so" "$file_path"; then
        printf "Patching %s with pam_u2f...\n" "$file_path"
        # Use sed to find the anchor pattern and append the new line after it.
        # A temporary file is used for safety, which then replaces the original.
        sudo sed "/${anchor_pattern}/a ${line_to_insert}" "$file_path" | sudo tee "${file_path}.tmp" >/dev/null
        sudo mv "${file_path}.tmp" "$file_path"
    else
        printf "%s already contains pam_u2f.so\n" "$file_path"
    fi
}


# === Main Execution ===

printf "[*] Installing pam-u2f if missing...\n"
# Check if the package is installed before attempting to install it.
if ! pacman -Q pam-u2f &>/dev/null; then
    sudo pacman -Sy --noconfirm pam-u2f
fi

printf "[*] Setting up U2F keys...\n"
mkdir -p "$U2F_DIR"
if [[ ! -s "$U2F_KEYS_FILE" ]]; then
    printf "Touch your primary YubiKey to register...\n"
    pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" > "$U2F_KEYS_FILE"

    printf "You can now register a backup key (optional). Touch it or press Ctrl-C to skip.\n"
    # The '|| true' ensures that the script doesn't exit if the user cancels.
    pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" -n >> "$U2F_KEYS_FILE" || true

    # Clean up trailing blank lines that might be added if the user cancels the backup registration.
    if [ -s "$U2F_KEYS_FILE" ]; then
        sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$U2F_KEYS_FILE"
    fi
else
    printf "U2F key file already exists at %s\n" "$U2F_KEYS_FILE"
fi

printf "[*] Backing up PAM configs...\n"
backup_file "$SYSTEM_AUTH_PAM_FILE"

printf "[*] Inserting pam_u2f.so into PAM configuration...\n"
insert_pam_line "$SYSTEM_AUTH_PAM_FILE"

printf "\n=== Done ===\n"
printf "Important: Test the new configuration in a new terminal or TTY before closing your current session.\n"
printf "Login and sudo should now require you to touch your YubiKey before entering your password.\n"
