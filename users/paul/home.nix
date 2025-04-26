{ config, pkgs, lib, inputs, hostname, ... }:

{
  # Import all module configurations
imports = [
  ../../modules/features/fish.nix
  ../../modules/features/git.nix
  ../../modules/features/vscode.nix
  ../../modules/features/fastfetch.nix
  # Comment out this conditional import for now
  # (if hostname == "x1" then ../../hosts/x1/home.nix else ../../hosts/macbook/home.nix)
];

  # User information
home.username = "paul";
home.homeDirectory = if pkgs.stdenv.isLinux then "/home/paul" else "/Users/paul";

  # Home Manager release
  home.stateVersion = "23.05";

  # Allow unfree packages
#  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.allowUnfreePredicate = (_: true);  

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
