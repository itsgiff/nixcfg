# NixOS Configuration for Intel NUC
# Maintained as part of nixcfg repository
# Last Update: May 2025

{ config, pkgs, lib, ... }:

# Import Modules
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/nixos/nfs.nix
    ../../modules/ssh.nix
  ];

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Enable firmware updates
  services.fwupd.enable = true;

  # Enable flakes and optimize Nix store
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "admin" ];
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
    hostName = "nuc";
    networkmanager.enable = true;
  };

  # Localization and timezone
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  # X11 and display configuration
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;    
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # GNOME Services
  services.gnome.gnome-keyring.enable = true;

  # Exclude GNOME Packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]);

  # System fonts
  fonts.packages = with pkgs; [
    font-awesome
    fira fira-mono fira-code fira-code-symbols
    dejavu_fonts
    noto-fonts noto-fonts-emoji
    material-icons
  ];

  # User configuration
  users.users.admin = {
    isNormalUser = true;
    description = "admin";
    home = "/home/admin";
    extraGroups = [ "docker" "wheel" "video" "networkmanager" ];
    shell = pkgs.fish;
  };

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide environment variables
  environment.variables = {
    EDITOR = "nano";
  };

  # Enable Firefox
  programs.firefox.enable = true;

  # Enable fish
  programs.fish.enable = true;

  # Default system packages
  environment.systemPackages = with pkgs; [
    curl nano wget tree htop jq
    cowsay unzip vim

    fish oh-my-fish
    git git-cliff git-crypt
    cmake

    docker docker-compose
    terraform kubectl kubernetes-helm eksctl

    iperf nmap nss

    firefox google-chrome
    vscode
    
    dconf 

  ];

  # SSH configuration
#  services.openssh = {
#    enable = true;
#    settings = {
#      PermitRootLogin = "no";
#      PasswordAuthentication = true;
#      KbdInteractiveAuthentication = false;
#    };
#  };


  # System state version - do not change
  system.stateVersion = "24.11";
}
