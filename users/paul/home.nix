{ config, pkgs, lib, inputs, hostname, ... }:

{
  # User information
  home.username = "paul";
  home.homeDirectory = if pkgs.stdenv.isLinux 
                      then "/home/${config.home.username}" 
                      else "/Users/${config.home.username}";
  
  # Home Manager Release
  home.stateVersion = "23.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);  

  # Basic packages that don't need dedicated modules
  home.packages = with pkgs; [
    htop
    ripgrep
  ] 
  # Conditional for fastfetch if available
  ++ (if pkgs ? fastfetch then [ pkgs.fastfetch ] else []);

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Dotfiles (if needed)
  home.file = {};
}