# ~/.nixcfg/modules/darwin/defaults.nix
# macOS system defaults configuration
{ config, pkgs, lib, ... }:

{
  # System defaults
  system.defaults = {
    # Dock settings
    dock = {
      autohide = false;
      orientation = "bottom";
      show-recents = false;
      mru-spaces = false;
      showhidden = true;
      mineffect = "scale";
      tilesize = 32;
    };
    
    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = true;
      FXPreferredViewStyle = "Nlsv"; # List view
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    
    # Global domain settings
    NSGlobalDomain = {
      # Disable "natural" scrolling
      "com.apple.swipescrolldirection" = false;
      
      # Full keyboard navigation
      AppleKeyboardUIMode = 3;
      
      # Disable automatic text modifications
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      
      # Key repeat settings
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      
      # Save panel expanded by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      
      # Print panel expanded by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    
    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
      ActuationStrength = 1; # 0 = light, 1 = medium, 2 = firm
    };
    
    # Login window settings
    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = false;
    };
    
    # Screenshots settings
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
  };
  
  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}