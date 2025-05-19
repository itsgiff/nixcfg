# ~/.nixcfg/users/admin/fish.nix

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

      # Docker Managememnt
      docker-update = "docker-pull; docker-up; docker-clean";
      docker-up = "sh /mnt/docker/compose.sh up";
      docker-down = "sh /mnt/docker/compose.sh down";
      docker-pull = "sh /mnt/docker/compose.sh pull";
      docker-clean = "docker image prune -af";
      docker-status = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";

      # Flake-based configuration aliases
      nixCfg = "cd ~/.nixcfg && $EDITOR flake.nix";
      nixEdit = "cd ~/.nixcfg && $EDITOR";
      nixSystem = "cd ~/.nixcfg && $EDITOR hosts/nuc/configuration.nix";
      nixHome = "cd ~/.nixcfg && $EDITOR users/admin/home.nix";
      
      # Flake building and updating
      nixFlakeCheck = "cd ~/.nixcfg && nix flake check";
      nixFlakeUpdate = "cd ~/.nixcfg && nix flake update";
      nixSwitch = "cd ~/.nixcfg && sudo nixos-rebuild switch --flake .#nuc";
      homeSwitch = "cd ~/.nixcfg && home-manager switch --flake .#admin@nuc";
      nixUpgrade = "cd ~/.nixcfg && nix flake update && sudo nixos-rebuild switch --flake .#nuc";
      fullUpdate = "cd ~/.nixcfg && nix flake update && sudo nixos-rebuild switch --flake .#nuc && home-manager switch --flake .#admin@nuc";
      
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

