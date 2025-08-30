# ~/.nixcfg/users/paul/fish.nix
# Paul-specific fish configuration that imports common settings from modules/fish.nix
# Adds user-specific aliases and customizations on top of the common configuration

{ config, pkgs, lib, hostname ? "x1", ... }:

let
  # Define platform-specific content
  isMacOS = pkgs.stdenv.isDarwin;
in {
  # Import the common fish configuration
  imports = [ ../../modules/fish.nix ];

  # Paul-specific Fish Shell configuration
  # These aliases will be merged with the common ones from modules/fish.nix
  programs.fish.shellAliases = {
    # User-specific aliases 
    nixHome = "cd ~/.nixcfg && $EDITOR users/paul/home.nix";
    homeSwitch = "cd ~/.nixcfg && home-manager switch --flake .#paul@${hostname}";
    fullUpdate = "cd ~/.nixcfg && nix flake update && ${if isMacOS then "sudo darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname} && home-manager switch --flake .#paul@${hostname}";
    
    # Infrastructure Management with path based on platform
    infra-scripts = "cd ${if isMacOS then "/Volumes/data/scripts/infrastructure" else "/mnt/data/scripts/infrastructure"}";
  } // (if isMacOS then {
    # macOS-specific aliases - only added when running on Darwin
    brewup = "brew update && brew upgrade && brew cleanup";
    macup = "softwareupdate --all --install --force";
  } else {
    # Linux-specific aliases for paul - only added when running on Linux
  });
}