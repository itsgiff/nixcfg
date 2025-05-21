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
      # cleanup = "zap"; # jesus this is destructive 
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
      "aws-iam-authenticator"
      "awscli"
      "azure-cli"
      "bat"
      "coreutils"
      "docker-compose"
      "docker-machine"
      "dockutil"
      "eksctl"
      "eza"
      "fastfetch"
      "fd"
      "findutils"
      "fish"
      "fzf"
      "gawk"
      "gh"
      "git-delta"
      "git-flow"
      "git-lfs"
      "helm"
      "httpie"
      "jq"
      "keychain"
      "kubectl"
      "m-cli"
      "macchina"
      "mas"
      "moreutils"
      "neovim"
      "ninja"
      "nmap"
      "nut"
      "openconnect"
      "openjpeg"
      "p7zip"
      "pandoc"
      "python"
      "rclone"
      "ripgrep"
      "rsync"
      "snappy"
      "speedtest-cli"
      "tcpdump"
      "telnet"
      "terraform"
      "trash"
      "tree"
      "vim"
      "watch"
      "xclip"
      "yq"
    ];
    
    # GUI macOS applications to install through Homebrew Cask
    casks = [
      # Add macOS apps that aren't available in nixpkgs
      "alfred"
      "appcleaner"
      "balenaetcher"
      "bartender"
      "brooklyn"
      "discord"
      "docker"
      "firefox"
      "ghostty"
      "gimp"
      "google-chrome"
      "google-cloud-sdk"
      "google-drive"
      "handbrake"
      "macfuse"
      "microsoft-office"
      "obsidian"
      "plex"
      "rectangle"
      "remarkable"
      "signal"
      "slack"
      "spotify"
      "tailscale"
      "the-unarchiver"
      "visual-studio-code"
      "vlc"
      "vnc-viewer"
      "whatsapp"
      "wifiman"
    ];
    
    # Mac App Store applications to install through mas
    masApps = {
      # Format: "AppName" = App Store ID;
      "Bitwarden" = 1352778147;
      "G App Launcher" = 1543803459;
      "HP Smart" = 1474276998;
      "Keynote" = 409183694;
      "Menu World Time" = 1446377255;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "reMarkable" = 1276493162;
      "Slack" = 803453959;
      "Tailscale" = 1475387142;
      "Windows App" = 1295203466;
    };
  };
}