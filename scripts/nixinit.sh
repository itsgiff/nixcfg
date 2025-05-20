#!/usr/bin/env bash
set -euo pipefail

# nixinit.sh - Bootstrap script for NixOS configuration
# Usage: wget -O- https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
# or: curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash

echo "=== NixOS Configuration Bootstrap ==="
echo "This script will set up your NixOS configuration using the nixcfg repository."

# Check if running as root and exit if so
if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: This script should not be run as root. Please run as a regular user."
  exit 1
fi

# Function to prompt for hostname - strict validation for only x1, nuc, or macbook
prompt_hostname() {
  read -p "Enter hostname for this machine (x1, nuc, or macbook): " hostname
  
  # Validate hostname is one of the expected values
  if [[ "$hostname" != "x1" && "$hostname" != "nuc" && "$hostname" != "macbook" ]]; then
    echo "ERROR: Hostname must be one of: x1, nuc, or macbook."
    echo "The flake configuration is only set up for these specific hosts."
    echo "Aborting."
    exit 1
  fi
  
  echo "$hostname"
}

# Backup original configuration files
backup_configs() {
  echo "Backing up original configuration files..."
  if [[ -f /etc/nixos/configuration.nix ]]; then
    sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
    echo "Backup created at /etc/nixos/configuration.nix.backup"
  fi
  
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix.backup
    echo "Backup created at /etc/nixos/hardware-configuration.nix.backup"
  fi
}

# Update hostname in configuration
update_hostname() {
  local hostname=$1
  if [[ -f /etc/nixos/configuration.nix ]]; then
    echo "Setting hostname to: $hostname"
    # Try to update existing hostname setting
    if grep -q "networking.hostname" /etc/nixos/configuration.nix; then
      sudo sed -i "s/networking.hostname = \".*\";/networking.hostname = \"$hostname\";/" /etc/nixos/configuration.nix
    else
      # If hostname isn't set, add it after the imports section
      sudo sed -i "/^}/i \ \ networking.hostname = \"$hostname\";" /etc/nixos/configuration.nix
    fi
  else
    echo "No configuration.nix found. Skipping hostname update."
  fi
}

# Add git to configuration if not present
add_git() {
  if [[ -f /etc/nixos/configuration.nix ]]; then
    echo "Adding git to configuration if not already present..."
    if grep -q "environment.systemPackages" /etc/nixos/configuration.nix; then
      if ! grep -q "git" /etc/nixos/configuration.nix; then
        sudo sed -i "/environment.systemPackages = with pkgs; \[/a \ \ \ \ git" /etc/nixos/configuration.nix
      fi
    else
      # If systemPackages isn't defined, add it before the closing brace
      sudo sed -i "/^}/i \ \ environment.systemPackages = with pkgs; [\n\ \ \ \ git\n\ \ ];" /etc/nixos/configuration.nix
    fi
  else
    echo "No configuration.nix found. Skipping git addition."
  fi
}

# Apply configuration
apply_config() {
  echo "Applying configuration changes..."
  if [[ -f /etc/nixos/configuration.nix ]]; then
    sudo nixos-rebuild switch
  else
    echo "No configuration.nix found. Skipping initial rebuild."
  fi
}

# Clone nixcfg repository
clone_repo() {
  echo "Cloning nixcfg repository..."
  if [ -d "$HOME/.nixcfg" ]; then
    echo "~/.nixcfg directory already exists. Backing it up..."
    mv "$HOME/.nixcfg" "$HOME/.nixcfg.bak.$(date +%Y%m%d%H%M%S)"
  fi
  
  # Clone from GitHub (public) then update remote to gitea (private)
  git clone https://github.com/itsgiff/nixcfg.git "$HOME/.nixcfg"
  cd "$HOME/.nixcfg"
  git remote set-url origin git@gitea:paul/nixcfg.git
  echo "Repository cloned and remote updated to use gitea."
}

# Enable experimental features
enable_experimental() {
  echo "Enabling experimental features for nix-command and flakes..."
  mkdir -p "$HOME/.config/nix"
  echo 'experimental-features = nix-command flakes' > "$HOME/.config/nix/nix.conf"
}

# Apply flake configuration
apply_flake() {
  local hostname=$1
  echo "Applying flake configuration for $hostname..."
  cd "$HOME/.nixcfg"
  sudo nixos-rebuild switch --flake ".#$hostname"
}

# Setup Docker group if on NUC
setup_docker_for_nuc() {
  local hostname=$1
  if [[ "$hostname" == "nuc" ]]; then
    echo "Checking Docker installation for NUC..."
    if command -v docker &> /dev/null; then
      echo "Docker is installed. Setting up Docker environment for NUC..."
      if groups | grep -q docker; then
        echo "User is already in the docker group. Running newgrp docker to activate it."
        # Note: newgrp will change the shell, so we can't continue executing commands after it
        # We'll just inform the user instead
        echo "After script completion, run 'newgrp docker' to activate the docker group."
        echo "Then run 'docker network create proxy' if needed."
      else
        echo "User is not in the docker group. Please ensure your configuration adds the user to the docker group."
        echo "After your next login or 'newgrp docker', you'll be able to use Docker commands."
      fi
    else
      echo "Docker not found. Please ensure your NixOS configuration enables Docker."
    fi
  fi
}

# Initialize fish shell enhancements (optional)
setup_fish() {
  read -p "Would you like to set up fish shell enhancements? [y/N]: " setup_fish_confirm
  if [[ "$setup_fish_confirm" == "y" || "$setup_fish_confirm" == "Y" ]]; then
    if command -v fish &> /dev/null; then
      echo "Setting up fish shell enhancements..."
      curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
      fish -c "omf install theme edan"
    else
      echo "Fish shell not found. Skipping fish setup."
    fi
  else
    echo "Skipping fish shell enhancements."
  fi
}

# Main execution
main() {
  # Get hostname
  hostname=$(prompt_hostname)
  
  # Basic setup for NixOS systems
  if [[ "$hostname" != "macbook" ]]; then
    backup_configs
    update_hostname "$hostname"
    add_git
    apply_config
  else
    echo "macOS detected. Skipping NixOS-specific configuration steps."
  fi
  
  # Get repos and setup flakes
  clone_repo
  enable_experimental
  
  # Apply flake for NixOS systems (macOS will need nix-darwin install first)
  if [[ "$hostname" != "macbook" ]]; then
    apply_flake "$hostname"
    
    # Check if this is NUC for Docker guidance
    setup_docker_for_nuc "$hostname"
  else
    echo "For macOS, please follow the nix-darwin installation steps before applying the flake."
    echo "See: https://github.com/LnL7/nix-darwin#install"
  fi
  
  # Optional setup
  setup_fish
  
  echo "=== Setup Complete ==="
  echo "Your Nix configuration has been initialized."
  
  if [[ "$hostname" == "nuc" ]]; then
    echo ""
    echo "IMPORTANT FOR NUC: Run the following commands to activate Docker:"
    echo "  newgrp docker"
    echo "  docker network create proxy  # if needed"
  fi
  
  echo ""
  echo "You may need to restart your system or login again for all changes to take effect."
}

# Run main function
main