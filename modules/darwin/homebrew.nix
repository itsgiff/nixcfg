# ~/.nixcfg/modules/darwin/homebrew.nix
# Homebrew integration for macOS
{ config, pkgs, lib, ... }:

{
  # Enable Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Uninstall packages not in spec
    };
    
    # Global Homebrew settings
    global = {
      brewfile = true;
      noLock = false;
    };
    
    # Homebrew taps
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/core"
      "homebrew/services"
    ];
    
    # Command line tools to install through Homebrew
    brews = [
      # Add CLI tools that aren't available in nixpkgs or
      # that work better when installed through Homebrew
      "mas" # Mac App Store CLI
    ];
    
    # GUI macOS applications to install through Homebrew Cask
    casks = [
      # Add macOS apps that aren't available in nixpkgs
      "alfred"
      "bartender"
    ];
    
    # Mac App Store applications to install through mas
    masApps = {
      # Format: "AppName" = App Store ID;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
    };
  };
}