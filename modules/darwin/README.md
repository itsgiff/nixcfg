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
  - Puts Homebrew's `bin` and `sbin` on PATH after the Nix profiles and before macOS (`environment.systemPath`)
  - Activation settings: no `brew update`/`upgrade` during a switch (run `brewup` instead); `cleanup = "check"`
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
    autoUpdate = false;   # switches never touch versions; use brewup
    upgrade = false;
    cleanup = "check";    # never removes; the switch stops on anything undeclared
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
- With `cleanup = "check"`, removing an entry from `homebrew.nix` doesn't uninstall it: run `brew uninstall <name>` yourself. If something is installed but not declared, the switch stops and lists it; declare it or uninstall it, then switch again.
- `"uninstall"` and `"zap"` are the removing modes (`zap` also deletes app data). They also remove undeclared Mac App Store apps, which is why this config uses `"check"`.
- To apply changes, run `sudo darwin-rebuild switch --flake .#macbook` (or the `nixSwitch` alias)