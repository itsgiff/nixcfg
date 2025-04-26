# NixOS Configuration for X1 ThinkPad
# Maintained as part of dotfiles repository
# Last updated: April 2025

{ config, pkgs, lib, inputs, hostname, ... }:

{
  imports = [ 
    # Hardware config
    ./hardware-configuration.nix
  ];

  # Bootloader settings
  boot = {
    # Systemd-boot configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel parameters
    kernel.sysctl = { "vm.swappiness" = 10; };
    
    # Plymouth boot splash
    plymouth = {
      enable = true;
      theme = "breeze";
    };
    initrd.systemd.enable = true;
  };

  # Networking settings
  networking = {
    hostName = "x1";
    networkmanager.enable = true;
    
    # Static host entries
    extraHosts = ''
      10.10.1.50 storage
      10.10.1.60 media
      10.10.2.8 nuc
    '';
  };

  
  # Time and locale settings
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  
  # X server and desktop environment
  services.xserver = {
    enable = true;
    
    # Display manager and desktop environment
    displayManager.gdm.enable = true;
    desktopManager = {
      gnome.enable = true;
      xterm.enable = false;
    };
    
    # Remove unnecessary packages
    excludePackages = [ pkgs.xterm ];
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  
  # GNOME specific services
  services.gnome.gnome-keyring.enable = true;
  
  # Exclude unnecessary GNOME packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    # Add any other GNOME packages to exclude
  ]);
  
  # System fonts
  fonts.packages = with pkgs; [
    font-awesome
    fira fira-mono fira-code fira-code-symbols
    dejavu_fonts
    powerline-fonts
    noto-fonts noto-fonts-emoji
    material-icons
  ];
  
  # CUPS printing service
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  
  # Avahi for printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  
  # Enable printer configuration tool
  programs.system-config-printer.enable = true;
  
  # NFS mount configurations
  # See: https://nixos.wiki/wiki/NFS
  
  # Basic filesystem definitions
  fileSystems = {
    "/mnt/files" = {
      device = "10.10.1.50:/volume1/files/Paul";
      fsType = "nfs";
    };
    "/mnt/backups" = {
      device = "10.10.1.50:/volume1/backups/x1";
      fsType = "nfs";
    };
    "/mnt/docker" = {
      device = "10.10.1.50:/volume1/docker";
      fsType = "nfs";
    };
    "/mnt/data" = {
      device = "10.10.1.50:/volume1/data";
      fsType = "nfs";
    };
  };
  
  # NFS service dependencies
  services.rpcbind.enable = true;
  
  # Systemd mount configurations with common options
  systemd.mounts = let 
    commonMountOptions = {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
    };
  in [
    (commonMountOptions // {
      what = "10.10.1.50:/volume1/files/Paul";
      where = "/mnt/files";
    })
    (commonMountOptions // {
      what = "10.10.1.50:/volume1/backups/x1";
      where = "/mnt/backups";
    })
    (commonMountOptions // {
      what = "10.10.1.50:/volume1/docker";
      where = "/mnt/docker";
    })
    (commonMountOptions // {
      what = "10.10.1.50:/volume1/data";
      where = "/mnt/data";
    })
  ];
  
  # Automount configurations for NFS shares
  systemd.automounts = let 
    commonAutoMountOptions = {
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "60";
      };
    };
  in [
    (commonAutoMountOptions // { where = "/mnt/files"; })
    (commonAutoMountOptions // { where = "/mnt/backups"; })
    (commonAutoMountOptions // { where = "/mnt/docker"; })
    (commonAutoMountOptions // { where = "/mnt/data"; })
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
  
  # User account configuration
  users.users.paul = {
    isNormalUser = true;
    description = "paul";
    shell = pkgs.fish;
    extraGroups = [ "audio" "lp" "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      # User-specific packages (currently managed in environment.systemPackages)
    ];
  };
  
  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;
  
  # Package configuration
  nixpkgs.config = {
    allowUnfree = true;
    # allowBroken = true; # Uncomment if needed
  };
  
  # System packages
  environment.systemPackages = with pkgs; [
    # CLI utilities
    curl wget tree htop jq
    cowsay unzip vim
    
    # System tools
    bluez fprintd plymouth
    nixos-bgrt-plymouth
    
    # Shell and development
    fish oh-my-fish
    git git-cliff git-crypt
    cmake
    
    # Cloud and containerization
    docker docker-compose
    terraform kubectl kubernetes-helm eksctl
    
    # Network tools
    iperf nmap openvpn nss
    
    # Security
    bitwarden gnupg
    
    # Desktop applications
    firefox google-chrome # brave (commented out)
    vscode
    signal-desktop-bin discord
    thunderbird
    obsidian
    
    # Graphics and media
    gimp feh flameshot
    cheese totem simple-scan
    
    # Office and productivity
    libreoffice-qt
    hunspell hunspellDicts.en_CA
    
    # Google integration
    
    # GNOME utilities and extensions
    dconf2nix dconf-editor
    epiphany
    gnome-tweaks seahorse
    gnome-settings-daemon
    gnome-characters gnome-clocks gnome-logs gnome-maps gnome-music
    
    # GNOME extensions
    gnomeExtensions.autohide-battery
    gnomeExtensions.gnome-bedtime
    gnomeExtensions.blur-my-shell
    gnomeExtensions.espresso
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
    
    # X11 and window management
    rofi picom
    flat-remix-gnome
    
    # Audio and video
    pavucontrol
    ytdownloader
    
    # Documentation and misc
    yelp
    
    # Games
    hitori iagno
    
    # Clipboard management
    clipboard-jh
  ];
  
  # Enable specific programs
  programs = {
    fish.enable = true;
    dconf.enable = true;
  };
  
  # Firmware updates
  services.fwupd.enable = true;
  
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
  
  # System version (important for NixOS upgrades - don't change after install)
  system.stateVersion = "23.05";
  
  # Nix features
  nix = {
    # Experimental features
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    
    # Automatic optimization
    settings.auto-optimise-store = true;
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  
  # Automatic system updates
  system.autoUpgrade.enable = true;
}
