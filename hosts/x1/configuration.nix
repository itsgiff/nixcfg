# NixOS Configuration for X1 ThinkPad
# Maintained as part of nixcfg repository
# Last updated: December 2025 (Upgraded to 25.11)

{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/nixos/nfs.nix
  ];

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  # Plymouth boot splash
  boot.plymouth.enable = true;
  boot.plymouth.theme ="breeze";
  # Enble systemd
  boot.initrd.systemd.enable = true;

  # Enable firmware updates
  services.fwupd.enable = true;

  # Enable flakes and optimise NIX store
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "paul" ];
      max-jobs = "auto";
      cores = 8;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
       automatic = true;
       dates = [ "weekly" ];
    };
  };

  # Networking configuration
  networking = {
    hostName = "x1";
    networkmanager.enable = true;
  };

  # Localization and timezone
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  # --- REFATOR: GNOME & GDM moved out of xserver (NixOS 25.11) ---
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.autoSuspend = false;
  services.desktopManager.gnome.enable = true;

  # X11 Configuration (Strictly X11 stuff only)
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Fingerprint reader support
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
      # Alternative driver if needed:
      # driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };

  # GNOME Services
  services.gnome.gnome-keyring.enable = true;
  
  # Exclude GNOME packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]);

  # System fonts
  fonts.packages = with pkgs; [
    font-awesome
    fira fira-mono fira-code fira-code-symbols
    dejavu_fonts
    powerline-fonts
    noto-fonts noto-fonts-color-emoji
    material-icons
  ];

  # PipeWire audio system
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # User configuration
  users.users.paul = {
    isNormalUser = true;
    description = "paul";
    home = "/home/paul";
    extraGroups = [ "audio" "lp" "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;    
  };
  
  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # System wide environmental variables
  environment.variables = {
    EDITOR = "nano";
  };

  # Default system packages
  environment.systemPackages = with pkgs; [
    curl nano wget tree htop jq
    cowsay unzip vim
    
    bluez fprintd plymouth
    nixos-bgrt-plymouth
    
    fish oh-my-fish
    git git-cliff git-crypt
    cmake
    
    home-manager

    docker docker-compose
    terraform kubectl kubernetes-helm eksctl
    
    iperf nmap openvpn nss dig
    
    # --- FIX: Renamed package for 25.11 ---
    bitwarden-desktop
    gnupg
  
    firefox google-chrome
    vscode
    signal-desktop discord
    thunderbird
    obsidian
    publii
    drawio
    
    gimp feh flameshot
    simple-scan
    
    libreoffice-qt
    hunspell hunspellDicts.en_CA
        
    dconf dconf2nix
    epiphany
    gnome-tweaks seahorse
    gnome-settings-daemon
    gnome-characters gnome-clocks gnome-logs gnome-maps gnome-music
    
    gnomeExtensions.autohide-battery
    gnomeExtensions.gnome-bedtime
    gnomeExtensions.blur-my-shell
    # gnomeExtensions.espresso
    gnomeExtensions.dash-to-dock
    gnomeExtensions.freon
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.user-themes
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.thinkpad-battery-threshold
    gnomeExtensions.just-perfection
    gnomeExtensions.transparent-top-bar
    gnomeExtensions.vitals
    gnomeExtensions.weather-oclock
    
    rofi picom
    flat-remix-gnome
    
    pavucontrol
    ytdownloader
  ];

  # Enable specific programs
  programs = {
    fish.enable = true;
    dconf.enable = true;
  };

  # System version (important for NixOS upgrades - don't change after install)
  system.stateVersion = "23.05";
}