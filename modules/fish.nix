# ~/.nixcfg/modules/fish.nix

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

      # Flake-based configuration aliases
      nixCfg = "cd ~/.nixcfg && $EDITOR flake.nix";
      nixEdit = "cd ~/.nixcfg && $EDITOR";
      nixSystem = "cd ~/.nixcfg && $EDITOR hosts/x1/configuration.nix";
      nixHome = "cd ~/.nixcfg && $EDITOR users/paul/home.nix";
      
      # Flake building and updating
      nixFlakeCheck = "cd ~/.nixcfg && nix flake check";
      nixFlakeUpdate = "cd ~/.nixcfg && nix flake update";
      nixSwitch = "cd ~/.nixcfg && sudo nixos-rebuild switch --flake .#x1";
      homeSwitch = "cd ~/.nixcfg && home-manager switch --flake .#paul@x1";
      nixUpgrade = "cd ~/.nixcfg && nix flake update && sudo nixos-rebuild switch --flake .#x1";
      fullUpdate = "cd ~/.nixcfg && nix flake update && sudo nixos-rebuild switch --flake .#x1 && home-manager switch --flake .#paul@x1";
      
      # System maintenance
      nixClean = "sudo nix-collect-garbage --delete-older-than 2d";
      nixOpt = "nix-store --optimise";
      restartDesktop = "sudo systemctl restart display-manager.service";
      
      # Legacy aliases (can be removed later)
      # homeCfg = "nano /home/paul/.config/home-manager/home.nix";
      # homeSwitch = "home-manager switch";
      # nixCfg = "sudo nano /etc/nixos/configuration.nix";
      # nixBuild = "sudo nixos-rebuild switch";
      # nixBoot = "sudo nixos-rebuild boot";
      # nixUpdate = "nix-channel --update";
      # nixUpgrade = "sudo nixos-rebuild switch --upgrade";
      # flakeCfg = "nano .config/home-manager/flake.nix";
      # hwCfg = "sudo nano /etc/nixos/hardware-configuration.nix";
      # update = "nixUpdate; nixUpgrade; homeSwitch";
    };
  };
}