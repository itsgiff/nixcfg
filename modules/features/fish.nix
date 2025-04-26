{ config, pkgs, ... }:

{
  # Fish Shell configuration
  programs.fish = {
    enable = true;

    shellAliases = {
      # General
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      c = "clear";  
      g = "git";

      # Home Manager and nixOS Configurations
      homeCfg = "nano /home/paul/.config/home-manager/home.nix";
      homeSwitch = "home-manager switch";
      nixCfg = "sudo nano /etc/nixos/configuration.nix";
      nixBuild = "sudo nixos-rebuild switch";
      nixClean = "sudo nix-collect-garbage --delete-older-than 2d";
      nixBoot = "sudo nixos-rebuild boot";
      nixOpt = "nix-store --optimise";
      nixUpdate = "nix-channel --update";
      nixUpgrade = "sudo nixos-rebuild switch --upgrade";
      flakeCfg = "nano .config/home-manager/flake.nix";
      hwCfg = "sudo nano /etc/nixos/hardware-configuration.nix";
      restartDesktop = "sudo systemctl restart display-manager.service";
      update = "nixUpdate; nixUpgrade; homeSwitch";
    };

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
      mkdcd = {
        description = "Make a directory tree and enter it";
        body = "mkdir -p $argv[1]; and cd $argv[1]";
      };
    };
  };
}