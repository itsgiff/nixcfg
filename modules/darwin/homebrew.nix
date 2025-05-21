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
      # cleanup = "zap"; # Uninstall packages not in spec
    };
    
    # Global Homebrew settings
    global = {
      brewfile = true;
      lockfiles = false;
    };
    
    # Homebrew taps - need to be installed manually 
    taps = [
     # "homebrew/bundle"
     # "homebrew/cask"
     ];
    
    # Command line tools to install through Homebrew
    brews = [
      "awscli"
      "aws-iam-authenticator"
      "bat"
      "coreutils"
      "docker-machine"
      "fd"
      "findutils"    
      "fzf"
      "fastfetch"
      "fish"
      "gawk"
      "gh"
      "keychain"
      "macchina"
      "mas"
      "m-cli"
      "ninja"
      "nmap"
      "nut"
      "snappy"
      "rclone"
      "ripgrep"
      "telnet"
      "terraform"
      "tree"
      "openconnect"
      "openjpeg"
      "python"

    ];
    
    # GUI macOS applications to install through Homebrew Cask
    casks = [
      # Add macOS apps that aren't available in nixpkgs
      "alfred"
      "appcleaner"
      "brooklyn"
      "bartender"
      "balenaetcher"
      "discord"
      "docker"
      "firefox"
      "ghostty"
      "gimp"
      "google-chrome"
      "google-drive"
      "handbrake" 
      "obsidian"
      "macfuse"
      "microsoft-office"
      "rectangle"      
      "remarkable"
      "signal"
      "slack"
      "spotify"
      "tailscale"
      "plex"
      "visual-studio-code"
      "vnc-viewer"
      "vlc"
      "whatsapp"
    ];
    
    # Mac App Store applications to install through mas
    masApps = {
      # Format: "AppName" = App Store ID;
      "Bitwarden" = 1352778147;
      "Keynote" = 409183694;
      "G App Launcher" = 1543803459;
      "Menu World Time" = 1446377255;
      "Numbers" = 409203825;
      "Pages" = 409201541;
    };
  };
}