# macOS-Specific Configuration Modules

This directory contains modular configurations specific to macOS (Darwin) systems.

## Module Overview

- **defaults.nix**: System preferences and defaults configuration
  - Dock settings (position, size, hiding behavior)
  - Finder preferences (file extensions, view style, UI elements)
  - Global domain settings (keyboard, text behavior, panels)
  - Trackpad behavior (clicking, gestures, sensitivity)
  - Login window and screenshot preferences
  - Keyboard mappings (Caps Lock to Control)

- **desktop.nix**: Desktop environment configuration
  - Environment variables (EDITOR, VISUAL, locale)
  - Homebrew environment variables (HOMEBREW_NO_ANALYTICS)
  - Core desktop utilities (bat, exa, fd, fzf, rectangle, m-cli)

- **homebrew.nix**: Homebrew package manager integration
  - Global Homebrew settings (brewfile, auto-update)
  - CLI tools via `brews` (mas)
  - GUI applications via `casks` (alfred, bartender)
  - Mac App Store applications via `masApps` (Pages, Numbers, Keynote)
  - Taps for additional repositories

## Usage

Import these modules in your macOS configuration:

```nix
# In hosts/macbook/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/desktop.nix
    # Uncomment when ready to use Homebrew
    # ../../modules/darwin/homebrew.nix
  ];
  
  # Your other configuration...
}
```

## Module Details

### defaults.nix
Manages system preferences and settings that you would typically configure through System Preferences/System Settings. Example settings:

```nix
# Finder settings
finder = {
  AppleShowAllExtensions = true;  # Show all file extensions
  QuitMenuItem = true;            # Enable Quit Finder menu item
  FXPreferredViewStyle = "Nlsv";  # Default to list view
}

# Key repeat settings (lower values = faster)
InitialKeyRepeat = 15;  # Delay until repeat begins
KeyRepeat = 2;          # Key repeat interval
```

### desktop.nix
Manages environment variables, fonts, system packages, and services. Includes the Homebrew environment variable to disable analytics:

```nix
# Environment variables 
environment.variables = {
  EDITOR = "nano";
  VISUAL = "code";
  LANG = "en_CA.UTF-8";
  HOMEBREW_NO_ANALYTICS = "1";  # Disable Homebrew analytics collection
};

# Useful CLI tools
environment.systemPackages = with pkgs; [
  bat    # Better cat with syntax highlighting
  fd     # User-friendly find alternative
  fzf    # Fuzzy finder
  m-cli  # macOS management from terminal
];
```

### homebrew.nix
Manages Homebrew packages, casks, and Mac App Store applications:

```nix
homebrew = {
  enable = true;
  onActivation = {
    cleanup = "zap";  # Removes packages not in the config
  };
  
  # GUI applications through Cask
  casks = [
    "alfred"
    "bartender"
  ];
  
  # Mac App Store apps
  masApps = {
    "Keynote" = 409183694;
  };
};
```

## Customization

Each module is designed to be modular and composable. You can:

1. Override settings by redefining them in your configuration.nix
2. Extend modules by adding new settings
3. Selectively import only the modules you need

## Notes

- The homebrew.nix module requires Homebrew to be installed.
- Some settings might require a logout/login or a restart to take effect.
- To update these settings, run `darwin-rebuild switch --flake .#macbook`