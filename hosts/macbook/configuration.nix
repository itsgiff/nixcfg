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
  nix.enable = false;  # Determinate Nix manages nix.conf (flakes already enabled)
  
  # User configuration
  users.users.paul = {
    home = "/Users/paul";
    # Login shell is set once with: chsh -s /run/current-system/sw/bin/fish
    # (nix-darwin only applies `shell` to users listed in users.knownUsers)
  };

  # Allowed login shells (/etc/shells): the Nix fish only.
  environment.shells = [ pkgs.fish ];

  # Set time zone
  time.timeZone = "America/Vancouver";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Basic programs
  programs.fish.enable = true;
  
  # Fonts, installed to /Library/Fonts/Nix Fonts (replaces the copies that
  # were installed by hand in ~/Library/Fonts)
  fonts.packages = with pkgs; [
    jetbrains-mono
    open-sans
  ];

  # Basic packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default   # claude-code via sadjow/claude-code-nix (same as the x1)
  ];

  # Prevent nix-darwin from managing these shell files
  environment.etc."zshrc".enable = false;
  environment.etc."zprofile".enable = false;
}