{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Home directory configuration
  home.username = "admin";
  home.homeDirectory = "/home/admin";
  
  # Fish shell config
  programs.fish = {
    enable = true;

    # Fish Aliases
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ll = "ls -la";
      update = "rebuild; docker-pull; docker-up; docker-clean";
      docker-up = "sh /mnt/docker/compose.sh up";
      docker-down = "sh /mnt/docker/compose.sh down";
      docker-pull = "sh /mnt/docker/compose.sh pull";
      docker-clean = "docker image prune -af";
      docker-status = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
      docker-logs = "docker logs -f";
      rebuild = "sudo nixos-rebuild switch --flake ~/.nixcfg#nuc";
      infra = "cd /mnt/data/scripts/infrastructure";
    };
    
    functions = {
      fish_gretting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
    }; 
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Paul Gifford";
    userEmail = "paul@giff.ca";
    aliases = {
      st = "status";
      co = "checkout";
      ci = "commit";
      br = "branch";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nano";
      color.ui = true;
      push.default = "simple";
    };
    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".idea/"
      ".vscode/"
    ];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Additional packages for the user
  home.packages = with pkgs; [
    firefox
    vscode
    htop
    jq
    bat
    ripgrep
    tmux
    fastfetch
  ];
  
  # Required for home-manager
  home.stateVersion = "23.11";
}
