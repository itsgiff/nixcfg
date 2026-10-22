# ~/.nixcfg/hosts/macbook/configuration.nix
{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [ 
    # Import darwin-specific modules
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/desktop.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # Basic system settings
  system.stateVersion = 4;
  system.primaryUser = "paul";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.enable = false;  # use nix-darwin with Determinate
  
  # User configuration
  users.users.paul = {
    home = "/Users/paul";
    shell = pkgs.fish; # Use fish as the default shell
  };

  # Set time zone
  time.timeZone = "America/Vancouver";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Basic programs
  programs.fish.enable = true;
  
  # Basic packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    htop
    ripgrep
  ];

  # Prevent nix-darwin from managing these shell files
  environment.etc."zshrc".enable = false;
  environment.etc."zprofile".enable = false;
}