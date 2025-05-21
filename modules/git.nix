{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.git;

    userName = "Paul Gifford";
    userEmail = "paul@giff.ca";

    aliases = {
      up = "pull --rebase";
      undo = "reset HEAD --soft";      
      sync = "!git pull --rebase && git push";
      # save = "!sh -c 'git add -A && git commit -m \"$1\" && git push origin main' -"; 
      save = ''!f() { 
          if git diff-index --quiet HEAD --; then
              git pull --rebase origin main &&
              git add -A &&
              git commit -m "$1" &&
              git push origin main || {
                  echo "⚠️ Changes not pushed due to conflicts or errors."
                  echo "ℹ️ Current status:"
                  git status --short
                  echo "\n❗ To resolve:"
                  echo "1. Check the conflicts with 'git status'"
                  echo "2. Resolve the conflicted files (look for conflict markers <<<, ===, >>>)"
                  echo "3. After fixing conflicts: 'git add <resolved-files>'" 
                  echo "4. Continue the rebase with 'git rebase --continue'"
                  echo "5. Push your changes with 'git push origin main'"
              }
          else
              echo "Stashing uncommitted changes first..." &&
              git stash &&
              git pull --rebase origin main &&
              git stash pop &&
              git add -A &&
              git commit -m "$1" &&
              git push origin main || {
                  echo "⚠️ Changes not pushed due to conflicts or errors."
                  echo "ℹ️ Current status:"
                  git status --short
                  echo "\n❗ To resolve:"
                  echo "1. Check the conflicts with 'git status'"
                  echo "2. Resolve the conflicted files (look for conflict markers <<<, ===, >>>)"
                  echo "3. After fixing conflicts: 'git add <resolved-files>'" 
                  echo "4. If you were in the middle of a rebase: 'git rebase --continue'"
                  echo "5. If you had stash conflicts: resolve them and 'git add' the fixed files"
                  echo "6. Commit with 'git commit -m \"Your message\"'"
                  echo "7. Push your changes with 'git push origin main'"
              }
          fi
      }; f'';
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
          "/mnt/data/infrastructure"
          "/mnt/data/run"        
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