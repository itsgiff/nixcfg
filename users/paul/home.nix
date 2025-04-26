{ config, pkgs, ... }:

{
  # Import all module configurations
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vscode.nix # must be installed in configuration.nix and settings managed here
    ./modules/fastfetch.nix
    # Add more modules here as you create them
    
    # Import host-specific configuration
    ./hosts/x1.nix
  ];

  # User information
  home.username = "paul";
  home.homeDirectory = "/home/paul";

  # Home Manager release
  home.stateVersion = "23.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);  

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
