# ~/.nixcfg/users/paul/fish.nix

{ config, pkgs, lib, hostname ? "x1", ... }:

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
      nixSystem = "cd ~/.nixcfg && $EDITOR hosts/${hostname}/configuration.nix";
      nixHome = "cd ~/.nixcfg && $EDITOR users/paul/home.nix";
      
      # Flake building and updating
      nixFlakeCheck = "cd ~/.nixcfg && nix flake check";
      nixFlakeUpdate = "cd ~/.nixcfg && nix flake update";
      nixSwitch = "cd ~/.nixcfg && ${if hostname == "macbook" then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname}";
      homeSwitch = "cd ~/.nixcfg && home-manager switch --flake .#paul@${hostname}";
      nixUpgrade = "cd ~/.nixcfg && nix flake update && ${if hostname == "macbook" then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname}";
      fullUpdate = "cd ~/.nixcfg && nix flake update && ${if hostname == "macbook" then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname} && home-manager switch --flake .#paul@${hostname}";
      
      # System maintenance
      nixClean = "sudo nix-collect-garbage --delete-older-than 2d";
      nixOpt = "nix-store --optimise";
      restartDesktop = "${if hostname == "macbook" then "echo 'Not applicable on macOS'" else "sudo systemctl restart display-manager.service"}";

      # Infrastructure Management
      infra-scripts = "cd ${if hostname == "macbook" then "/Volumes/data/scripts/infrastructure" else "/mnt/data/scripts/infrastructure"}";
    
    }; 

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";      
      };
    };
  };
}