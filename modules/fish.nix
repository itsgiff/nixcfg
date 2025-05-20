# ~/.nixcfg/modules/fish.nix
# This is the common fish shell configuration for all users
# It contains core aliases and settings that are shared across users and platforms
# User-specific configurations import this module and extend/override as needed

{ config, pkgs, lib, hostname ? "x1", ... }:

let
  # Define platform-specific content
  isMacOS = pkgs.stdenv.isDarwin;
in {
  # Common Fish Shell configuration
  programs.fish = {
    enable = true;

    # Add initialization to source nix-darwin paths on macOS
    interactiveShellInit = lib.optionalString isMacOS ''
      # Source nix-darwin environment if available
      if test -e /etc/static/fish/config.fish
        source /etc/static/fish/config.fish
      end

      # Add nix-darwin paths to PATH if needed
      if test -d /run/current-system/sw/bin
        fish_add_path /run/current-system/sw/bin
      end
      
      # Add home-manager path if it exists
      if test -d $HOME/.nix-profile/bin
        fish_add_path $HOME/.nix-profile/bin
      end
      
      # Add local bin directory to PATH
      if test -d $HOME/.local/bin
        fish_add_path $HOME/.local/bin
      end
    '';

    shellAliases = {
      # General aliases used by all users
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
      nixPull = "cd ~/.nixcfg && git pull";
      
      # Flake building and updating
      nixFlakeCheck = "cd ~/.nixcfg && nix flake check";
      nixFlakeUpdate = "cd ~/.nixcfg && nix flake update";
      nixSwitch = "cd ~/.nixcfg && ${if isMacOS then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname}";
      nixUpgrade = "cd ~/.nixcfg && nix flake update && ${if isMacOS then "darwin-rebuild" else "sudo nixos-rebuild"} switch --flake .#${hostname}";
      
      # System maintenance
      nixClean = "sudo nix-collect-garbage --delete-older-than 2d";
      nixOpt = "nix-store --optimise";
      restartDesktop = "${if isMacOS then "echo 'Not applicable on macOS'" else "sudo systemctl restart display-manager.service"}";
    };

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";      
      };
    };
  };
}