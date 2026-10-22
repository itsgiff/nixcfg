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

- **homebrew.nix**: Homebrew package manager integration
  - Activation settings (auto-update and upgrade on every switch; cleanup disabled)
  - CLI tools via `brews`
  - GUI applications via `casks`
  - Mac App Store applications via `masApps`
  - Taps for additional repositories

## Usage

These modules are imported by `hosts/macbook/configuration.nix`:

```nix
# In hosts/macbook/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/desktop.nix
    ../../modules/darwin/homebrew.nix
  ];
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
Sets environment variables, including the Homebrew variable that disables analytics:

```nix
# Environment variables 
environment.variables = {
  EDITOR = "nano";
  VISUAL = "code";
  LANG = "en_CA.UTF-8";
  HOMEBREW_NO_ANALYTICS = "1";  # Disable Homebrew analytics collection
};
```

CLI tools such as bat, fd and fzf are installed through `homebrew.nix`, not here.

### homebrew.nix
Manages Homebrew packages, casks, and Mac App Store applications:

```nix
homebrew = {
  enable = true;
  onActivation = {
    autoUpdate = true;
    upgrade = true;
    # cleanup = "zap";  # disabled: removes anything not listed
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
- Because `cleanup` is disabled, removing an entry from `homebrew.nix` does not uninstall it.
- To apply changes, run `sudo darwin-rebuild switch --flake .#macbook` (or the `nixSwitch` alias)