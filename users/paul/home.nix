{ config, pkgs, lib, inputs, hostname, ... }:

let
  # Map of hostnames to usernames
  userMapping = {
    "x1" = "paul";         # ThinkPad
    "macbook" = "paul";    # MacBook
    "nuc" = "admin";       # NUC with admin username
    # Add other machines as needed
  };
  
  # Get username based on hostname, defaulting to "paul" if not found
  username = userMapping.${hostname} or "paul";
in
{
  # Dynamic user information based on hostname
  home.username = username;
  home.homeDirectory = 
    if pkgs.stdenv.isLinux then "/home/${username}" 
    else if pkgs.stdenv.isDarwin then "/Users/${username}"
    else "/home/${username}";  # Fallback

  # Import all your modules
  imports = [
    ../../modules/fastfetch.nix
    ../../modules/git.nix
    ../../modules/vscode.nix
    ../../modules/fish.nix
  ];

  # Home Manager release
  home.stateVersion = "23.11";

  # Basic packages that don't need dedicated modules
  home.packages = with pkgs; [
    htop
    ripgrep
  ] ++ (if pkgs ? fastfetch then [ pkgs.fastfetch ] else []);

  # Dotfiles (if needed)
  home.file = {};

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}