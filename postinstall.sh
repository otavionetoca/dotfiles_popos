#!/bin/bash
# post_install.sh
# A basic post-installation script for Pop!_OS.
# This script updates the system, installs essential packages,
# configures Snap and Flatpak, sets up a firewall, and performs a few custom tweaks.
# Always review and test before running on your main system.

set -e # Exit on any error

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

# Function: Check Internet connectivity
check_internet() {
    echo "Checking internet connectivity..."
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        echo "No internet connection detected. Exiting postinstall script."
        exit 1
    fi
}
check_internet

mkdir ~/nomachine_install
cd ~/nomachine_install
curl -o nomachine.deb https://download.nomachine.com/download/8.16/Linux/nomachine_8.16.1_1_amd64.deb
dpkg -i nomachine.deb

apt install git gh google-chrome-stable -y

ssh-keygen -t ed25519 -C "otavio.netoca+popos@gmail.com" -f ~/.ssh/id_ed25519 -N ""
gh auth login -h github.com -w -s admin:public_key
gh ssh-key add ~/.ssh/id_ed25519.pub

mkdir ~/git-clones
cd ~/git-clones
gh repo clone otavionetoca/dotfiles_popos
cd ~/dotfiles_popos

mkdir ~/.config/i3
cp ~/dotfiles_popos/.config/i3/config ~/.config/i3/

git config --global user.email "otavio.netoca+popos@gmail.com"
git config --global user.name "Netoca PopOS"
git config --global core.editor "vim"

# Add VSCode apt repo
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

# Add Fish shell ppa
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update

# Remove unused apps
apt purge firefox libreoffice-*

# Update system
echo "Updating package lists..."
apt update -y

echo "Upgrading installed packages..."
apt upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt install -y vim curl wget build-essential \
    flameshot gnome-control-center \
    i3 alacritty fish tmux polybar

# Clean up unused packages
echo "Cleaning up..."
apt autoremove -y

# Install Fish v3.7.x
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
source
fish
fisher install jorgebucaran/fisher
fisher install jorgebucaran/nvm.fish
fisher install jhillyerd/plugin-git
fisher install pure-fish/pure
# TODO: clone fish config

# Install TPM for tmux
mkdir -p ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# TODO: clone tmux config and put on ~/.tmux.conf
tmux source ~/.tmux.conf

# TODO: clone alacritty config only after fish and tmux are installed, otherwise it breaks
# TODO: clone polybar config only 

echo "Post-installation setup complete!"
