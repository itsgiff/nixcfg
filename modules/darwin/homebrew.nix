# ~/.nixcfg/modules/darwin/homebrew.nix
# Homebrew integration for macOS
{ config, pkgs, lib, ... }:

{
  # Put Homebrew on PATH for every shell: after the Nix profiles (order 1000),
  # before macOS's /usr/local/bin:/usr/bin:... (order 1200).
  environment.systemPath = lib.mkOrder 1100 [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
  ];

  # Enable Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      # No automatic brew update/upgrade during nixSwitch: upgrades happen
      # only when run on purpose (brewup), so a switch never changes app versions.
      autoUpdate = false;
      upgrade = false;
      # cleanup = "zap"; # jesus this is destructive 
    };
    
    # Global Homebrew settings
    global = {
      brewfile = true;
    };
    
    # Homebrew taps - need to be installed manually 
    taps = [
       "msitarzewski/brew-browser"
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
      "fnm"
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
      "pnpm"
      "rclone"
      "ripgrep"
      "rsync"
      "rustup"
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
      "antigravity"
      "appcleaner"
      "balenaetcher"
      "bartender"
      "bitwarden"
      "brew-browser"
      "brooklyn"
      "chatgpt"
      "claude-code"
      "discord"
      # "docker-desktop"
      "drawio"
      "firefox"
      "geekbench"
      # "ghostty"
      # "gimp"
      "google-chrome"
      "gcloud-cli"
      "google-drive"
      "handbrake-app"
      # "librewolf"
      "macfuse"
      "microsoft-office"
      "obsidian"
      "obs"
      "omnigraffle"
      "plex"
      "publii"
      # "raycast"
      # "rectangle"
      "remarkable"
      "signal"
      # "slack"
      "spotify"
      # "tailscale-app"
      "the-unarchiver"
      "vlc"
      "realvnc-connect-viewer"
      "whatsapp"
      "wifiman"
    ];
    
    # Mac App Store applications to install through mas
    masApps = {
      # Format: "AppName" = App Store ID;
      # "Bitwarden" = 1352778147; # moved to casks
      "G App Launcher" = 1543803459;
      # "HP Smart" = 1474276998;
      # "Keynote" = 409183694;
      "Menu World Time" = 1446377255;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
      # "reMarkable" = 1276493162;
      # "Slack" = 803453959;
      # "Tailscale" = 1475387142;
      # "Windows App" = 1295203466;
    };
  };
}