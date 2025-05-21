{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.git;

    userName = "Paul Gifford";
    userEmail = "paul@giff.ca";

    aliases = {
      # Basic aliases
      up = "pull --rebase";
      undo = "reset HEAD~1 --soft";      
      unstage = "reset HEAD --";
      sync = "!git pull --rebase && git push";
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      fix = "commit --amend --no-edit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";

      # Advanced aliases with functions
      save = "!f() { if git diff-index --quiet HEAD --; then git pull --rebase origin main && git add -A && git commit -m \"$1\" && git push origin main || { echo \"Changes not pushed due to conflicts or errors.\"; echo \"Current status:\"; git status --short; echo \"\n❗ To resolve:\"; echo \"1. Check the conflicts with 'git status'\"; echo \"2. Resolve the conflicted files (look for conflict markers <<<, ===, >>>)\"; echo \"3. After fixing conflicts: 'git add <resolved-files>'\"; echo \"4. Continue the rebase with 'git rebase --continue'\"; echo \"5. Push your changes with 'git push origin main'\"; }; else echo \"Stashing uncommitted changes first...\" && git stash && git pull --rebase origin main && git stash pop && git add -A && git commit -m \"$1\" && git push origin main || { echo \"Changes not pushed due to conflicts or errors.\"; echo \"Current status:\"; git status --short; echo \"\n To resolve:\"; echo \"1. Check the conflicts with 'git status'\"; echo \"2. Resolve the conflicted files (look for conflict markers <<<, ===, >>>)\"; echo \"3. After fixing conflicts: 'git add <resolved-files>'\"; echo \"4. If you were in the middle of a rebase: 'git rebase --continue'\"; echo \"5. If you had stash conflicts: resolve them and 'git add' the fixed files\"; echo \"6. Commit with 'git commit -m \\\"Your message\\\"'\"; echo \"7. Push your changes with 'git push origin main'\"; }; fi; }; f";
      
      # 1. Git update - Update current branch with upstream changes safely
      update = "!f() { BRANCH=$(git rev-parse --abbrev-ref HEAD) && git fetch origin && git rebase --autostash origin/$BRANCH || echo \"Conflicts detected. Resolve them and run 'git rebase --continue'\"; }; f";
      
      # 2. Git sync-all - Update all branches and prune stale references
      sync-all = "!f() { git fetch --all --prune && echo \"✅ All remote branches updated and stale branches pruned\"; }; f";
      
      # 3 & 4. Git undo/uncommit - Undo the last commit but keep changes
      uncommit = "!f() { echo \"This will undo your last commit but keep the changes. Continue? [y/N]\" && read answer && [ \"$answer\" = \"y\" ] && git reset HEAD~1 --soft && echo \"✅ Last commit undone, changes preserved\"; }; f";
      
      # 6. Git cleanup - Clean up local branches that have been merged
      cleanup = "!f() { git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d && echo \"✅ Merged branches cleaned up\"; }; f";
      
      # 7. Git recent - Show recent branches you've worked on
      recent = "!git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format='%(refname:short)'";
      
      # 8. Git changes - See what you've changed since last pull
      changes = "!f() { CURRENT=$(git rev-parse HEAD) && BRANCH=$(git rev-parse --abbrev-ref HEAD) && REMOTE=$(git rev-parse origin/$BRANCH) && git log --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr)%Creset' $REMOTE..$CURRENT; }; f";
      
      # 10. Git new-branch - Create and switch to a new branch
      new-branch = "!f() { git checkout -b $1 && git push -u origin $1; }; f";
      
      # 11. Git wip - Save a "Work in Progress" commit
      wip = "!f() { git add . && git commit -m \"WIP: $(date)\" && echo \"✅ Work in progress saved\"; }; f";
      
      # 12. Git unwip - Undo the last WIP commit
      unwip = "!f() { git log -1 --pretty=%B | grep -q \"^WIP:\" && git reset HEAD~1 --soft || echo \"⚠️ Last commit is not a WIP commit\"; }; f";
      
      # 13. Git nix-switch - Update and switch NixOS config
      nix-switch = "!f() { cd ~/.nixcfg && git add . && git commit -m \"feat: $1\" && HOSTNAME=$(hostname) && if [[ \"$HOSTNAME\" == \"macbook\" ]]; then darwin-rebuild switch --flake .#macbook; elif [[ \"$HOSTNAME\" == \"nuc\" ]]; then sudo nixos-rebuild switch --flake .#nuc; else sudo nixos-rebuild switch --flake .#x1; fi; }; f";
      
      # 15. Git changelog - Generate a simple changelog
      changelog = "!f() { git log --pretty=format:'%s' --reverse $(git describe --tags --abbrev=0)..HEAD | grep -v \"Merge\" | sed 's/^/- /'; }; f";
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