# ~/.nixcfg/users/admin/fish.nix
# Admin-specific fish configuration that imports common settings from modules/fish.nix
# Adds user-specific aliases and customizations on top of the common configuration
# Admin user is only ever on Linux (specifically NUC)

{ config, pkgs, lib, hostname ? "nuc", ... }:

{
  # Import the common fish configuration
  imports = [ ../../modules/fish.nix ];

  # Admin-specific Fish Shell configuration  
  # These aliases will be merged with the common ones from modules/fish.nix
  programs.fish.shellAliases = {
    # User-specific aliases
    nixHome = "cd ~/.nixcfg && $EDITOR users/admin/home.nix";
    homeSwitch = "cd ~/.nixcfg && home-manager switch --flake .#admin@${hostname}";
    fullUpdate = "cd ~/.nixcfg && nix flake update && sudo nixos-rebuild switch --flake .#${hostname} && home-manager switch --flake .#admin@${hostname}";
    
    # Infrastructure Management - admin always uses Linux path
    infra-scripts = "cd /mnt/data/scripts/infrastructure";
    
    # Docker Management - admin-specific for NUC server
    docker-update = "docker-pull; docker-up; docker-clean";
    docker-up = "sh /mnt/docker/compose.sh up";
    docker-down = "sh /mnt/docker/compose.sh down";
    docker-pull = "sh /mnt/docker/compose.sh pull";
    docker-clean = "docker image prune -af";
    docker-status = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
  };
}