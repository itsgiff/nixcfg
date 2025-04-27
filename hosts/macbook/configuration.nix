# ~/.nixcfg/hosts/macbook/configuration.nix
{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [ /* modules later */ ];
  
  # Basic system settings
  system.stateVersion = 4;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.enable = true;
  
  # User configuration
  users.users.paul = {
    home = "/Users/paul";
    shell = pkgs.zsh; # Adjust to your preferred shell
  };

  # Set time zone
  time.timeZone = "America/Vancouver"; # Adjust to your time zone

nixpkgs.config.allowUnfree = true;

  # Basic system configuration
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
    };
    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
    };
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false; # "Natural" scrolling
      AppleKeyboardUIMode = 3; # Full keyboard navigation
    };
  };
}