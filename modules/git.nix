{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName = "Paul Gifford";
    userEmail = "paul@giff.ca";

    aliases = {
      up = "pull --rebase";
      sync = "!git pull --rebase && git push";
      save = "!f() { git add -A && git commit -m \"$1\" && git push origin main; }; f";
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    # Common global ignore list (NixOS + macOS + Synology + dev environments)
    ignores = [
      # Synology junk
      "@eaDir/"
      "**/@eaDir/"
      "**/*SynoEAStream*"

      # macOS junk
      ".DS_Store"
      ".AppleDouble"
      "._*"

      # Editor/IDE cruft
      "*.swp"
      "*~"
      ".idea/"
      ".vscode/"
      "*.code-workspace"

      # Python build artifacts
      "__pycache__/"
      "*.py[cod]"
      "*.pyo"

      # Node/JavaScript
      "node_modules/"
      ".npm/"
      ".yarn/"

      # Logs/temp
      "*.log"
      "*.tmp"
      ".Trash-*"

      # System files
      ".env"
      ".env.*"
      ".coverage"
    ];

    extraConfig = {
      init.defaultBranch = "main";

      core = {
        editor = "code --wait";
        pager = "less";
        whitespace = "trailing-space,space-before-tab";
        fileMode = true;
        autocrlf = "input";
        # Removed hardcoded excludesFile - Home Manager handles this
      };

      color.ui = "auto";
      status.short = true;

      merge.ff = "only";
      log.date = "iso";

      format.pretty = "%C(yellow)%h%Creset %ad %s%Cgreen [%cn]";

      help.autocorrect = 5;

      pull.rebase = false;

      # Platform-specific safe directories
      safe.directory = lib.mkMerge [
        # Common directories (if any)
        []
        
        # Linux-specific directories
        (lib.mkIf pkgs.stdenv.isLinux [
          "/mnt/files/Google Drive/Projects/pull-request-coffee/operations"
          "/mnt/data/dotfiles"
          "/mnt/data/infrastructure"
          "/mnt/data/run"        
          "/mnt/data/nixconfig"
          "/mnt/data/scripts"
          "/mnt/data/ssh-keys"
          "/mnt/data"
          "/mnt/files"
        ])
        
        # macOS-specific directories (add any if needed)
        (lib.mkIf pkgs.stdenv.isDarwin [
          # Add macOS paths that need safe.directory here
        ])
      ];
    };
  };
}