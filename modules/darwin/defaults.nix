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
      minimize-to-application = true;
      # Chrome is the only pinned app, by choice (same on the x1). Anything
      # pinned by hand is removed at the next switch.
      persistent-apps = [ "/Applications/Google Chrome.app" ];
      persistent-others = [ ];
      # Hot corners: bottom-left Mission Control, bottom-right off
      wvous-bl-corner = 2;
      wvous-br-corner = 1;
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
      AppleShowAllFiles = true;          # show hidden files
      NewWindowTarget = "Home";          # new windows open the home folder
      FXRemoveOldTrashItems = true;      # empty Trash items after 30 days
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
    };
    
    # Global domain settings
    NSGlobalDomain = {
      # Appearance
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      NSTableViewDefaultSizeMode = 2;    # medium sidebar icons and rows
      "com.apple.sound.beep.feedback" = 1; # play feedback when volume changes

      # Disable "natural" scrolling
      "com.apple.swipescrolldirection" = false;
      
      # No two-finger swipe to go back/forward in browsers
      AppleEnableSwipeNavigateWithScrolls = false;

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
      FirstClickThreshold = 1;           # click pressure: medium
      TrackpadPinch = true;
      TrackpadRotate = true;
      # Gestures: 2 = swipe between pages/spaces, Mission Control, App Expose
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3; # Notification Center
    };

    # Mouse tracking speed
    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;
    
    # Menu bar
    menuExtraClock = {
      ShowDate = 0;                      # when space allows
      ShowDayOfWeek = true;
      ShowAMPM = true;
    };
    controlcenter.BatteryShowPercentage = true;

    ActivityMonitor.ShowCategory = 100;  # all processes

    # Login window settings
    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = false;
    };
    
    # Screenshots settings
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      target = "file";
    };

    # Stage Manager and window tiling
    WindowManager = {
      GloballyEnabled = false;           # Stage Manager off
      EnableTopTilingByEdgeDrag = false;
      EnableTiledWindowMargins = false;
      HideDesktop = false;
      StandardHideWidgets = false;
    };
    spaces.spans-displays = true;        # "Displays have separate Spaces" off
  };
  
  # Screensaver after 5 minutes. A per-host setting with no nix-darwin option,
  # so it is written for the user after activation.
  system.activationScripts.postActivation.text = ''
    sudo --user=${config.system.primaryUser} -- defaults -currentHost write com.apple.screensaver idleTime -int 300
  '';

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}