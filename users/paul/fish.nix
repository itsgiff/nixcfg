# ~/.nixcfg/users/paul/fish.nix

{ config, pkgs, lib, ... }:

{
  # Fish Shell configuration
  programs.fish = {
    enable = true;

    shellAliases = {
      # General
      ".." = "cd ..";
      "..." = "cd ../..";
      ll = "ls -la";
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

      # Infrastucture Management
      infra-scripts = "cd /mnt/data/scripts/infrastructure";
    
    }; 

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";      
    };
  };
 };
}

