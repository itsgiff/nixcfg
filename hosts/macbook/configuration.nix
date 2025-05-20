# ~/.nixcfg/hosts/macbook/configuration.nix
{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [ /* modules later */ ];
  
  # Basic system settings
  system.stateVersion = 4;
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

  # Basic system configuration
  system.defaults = {
    dock = {
      autohide = false;
      orientation = "bottom";
      show-recents = false;
      mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false; # "Natural" scrolling
      AppleKeyboardUIMode = 3; # Full keyboard navigation
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    # Add trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
  };
  
  # Basic programs
  programs.fish.enable = true;
  
  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    curl
    home-manager
    wget
  ];
}