#!/bin/bash

# Directory paths
config_dir="$HOME/.config"
dotfiles_dir="./dotfiles"
packages_file="./packages"


check_internet() {
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "Internet connection is active."
    else
        echo "No internet connection. Please check your network and try again."
        exit 1
    fi
}

check_internet

# Check if the packages file exists
if [ ! -f "$packages_file" ]; then
    echo "Packages file $packages_file does not exist"
    exit 1
fi

# Read packages from the file
packages=($(cat "$packages_file"))

# Check if paru is installed
if ! command -v paru &> /dev/null; then
    read -p "paru is not installed. Do you want to install it? (y/n): " install_paru
    if [ "$install_paru" != "${install_paru#[Yy]}" ]; then
        echo "Installing paru..."
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si
        cd ..
        rm -rf paru
    else
        echo "paru is required for this script. Exiting."
        exit 1
    fi
fi

# Rename existing folders in .config if they exist in dotfiles
for dir in "$dotfiles_dir"/*; do
    dir_name=$(basename "$dir")
    if [ -d "$config_dir/$dir_name" ]; then
        mv "$config_dir/$dir_name" "$config_dir/${dir_name}-backup"
        echo "Renamed existing $config_dir/$dir_name to $config_dir/${dir_name}-backup"
    fi
done

# Update package list and install packages using paru
paru -Syu --noconfirm
for package in "${packages[@]}"; do
    paru -S --noconfirm $package
done

# Copy configuration files from dotfiles to .config
if [ -d "$dotfiles_dir" ]; then
    cp -r "$dotfiles_dir/." "$config_dir/"
    echo "Copied configuration files from $dotfiles_dir to $config_dir"
else
    echo "Dotfiles directory $dotfiles_dir does not exist"
    exit 1
fi

echo "Installation and configuration complete."
