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
      
      # Git commit format guide shorthand
      cmf = "git-commit-format";
    };

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";      
      };
      
      # Git commit format helper function
        git-commit-format = {
          description = "Show conventional commit format examples";
          body = ''
            echo "
            "$(set_color --bold)"Conventional Commit Format"$(set_color normal)"
            =========================
            
            Format: "$(set_color yellow)"<type>(<scope>): <description>"$(set_color normal)"
            
            "$(set_color --bold)"Types:"$(set_color normal)"
            "$(set_color green)"feat"$(set_color normal)"     - A new feature or enhancement
            "$(set_color green)"fix"$(set_color normal)"      - A bug fix
            "$(set_color green)"docs"$(set_color normal)"     - Documentation changes only
            "$(set_color green)"style"$(set_color normal)"    - Changes that don't affect code meaning (formatting)
            "$(set_color green)"refactor"$(set_color normal)" - Code restructuring without feature changes
            "$(set_color green)"perf"$(set_color normal)"     - Performance improvements
            "$(set_color green)"test"$(set_color normal)"     - Test additions or modifications
            "$(set_color green)"chore"$(set_color normal)"    - Maintenance tasks, dependency updates
            "$(set_color green)"ci"$(set_color normal)"       - Changes to CI configuration
            
            "$(set_color --bold)"Scopes:"$(set_color normal)"
            "$(set_color cyan)"core"$(set_color normal)"     - Base configuration
            "$(set_color cyan)"macOS"$(set_color normal)"    - macOS/darwin-specific changes
            "$(set_color cyan)"nixos"$(set_color normal)"    - NixOS-specific changes
            "$(set_color cyan)"fish"$(set_color normal)"     - Fish shell configuration
            "$(set_color cyan)"modules"$(set_color normal)"  - Feature modules changes
            "$(set_color cyan)"home"$(set_color normal)"     - Home-manager configurations
            "$(set_color cyan)"flake"$(set_color normal)"    - Changes to flake.nix
            
            "$(set_color --bold)"Examples:"$(set_color normal)"
            "$(set_color yellow)"feat(macOS):"$(set_color normal)" add homebrew integration
            "$(set_color yellow)"fix(fish):"$(set_color normal)" resolve PATH issues on macOS
            "$(set_color yellow)"docs:"$(set_color normal)" update status after macOS implementation
            "$(set_color yellow)"refactor(modules):"$(set_color normal)" improve cross-platform compatibility
            "$(set_color yellow)"chore:"$(set_color normal)" update flake inputs
            "
          '';
        };
      
      # Smart Git commit with conventional format
        gcm = {
          description = "Git commit with conventional format message";
          body = ''
            if test (count $argv) -eq 0
              # No arguments provided, show the format guide first
              git-commit-format
              echo ""
              echo "\x1B[33mUsage:\x1B[0m gcm \"feat(scope): your message\""
              return 1
            end
            
            # Check if the commit message follows the convention format
            if not string match -q -r "^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\(.+\))?:.+" $argv[1]
              echo "\x1B[31mWarning:\x1B[0m Commit message doesn't follow the convention format."
              echo "See the correct format below:"
              git-commit-format
              
              # Ask if they want to proceed anyway
              read -l -P "Proceed with this commit message anyway? [y/N] " confirm
              if test "$confirm" != "y" -a "$confirm" != "Y"
                return 1
              end
            end
            
            # Proceed with commit
            git commit -m "$argv[1]"
          '';
        };
    };
  };
}