# ~/.nixcfg/users/paul/fish.nix
# Paul-specific fish configuration that imports common settings from modules/fish.nix
# Adds user-specific aliases and customizations on top of the common configuration

{ config, pkgs, lib, hostname ? "x1", ... }:

let
  # Define platform-specific content
  isMacOS = pkgs.stdenv.isDarwin;
  rebuild = if isMacOS then "sudo darwin-rebuild" else "sudo nixos-rebuild";
in {
  # Import the common fish configuration
  imports = [ ../../modules/fish.nix ];

  # Paul-specific Fish Shell configuration
  # These aliases will be merged with the common ones from modules/fish.nix
  programs.fish.shellAliases = {
    # User-specific aliases
    nixHome = "cd ~/.nixcfg && $EDITOR users/paul/home.nix";

    # Infrastructure Management with path based on platform
    infra-scripts = "cd ${if isMacOS then "/Volumes/data/scripts/infrastructure" else "/mnt/data/scripts/infrastructure"}";
  } // (if isMacOS then {
    # macOS-specific aliases - only added when running on Darwin
    brewup = "brew update && brew upgrade && brew cleanup";
    macup = "softwareupdate --all --install --force";
  } else {
    # Linux-specific aliases for paul - only added when running on Linux
  });

  # fullUpdate: pull, update flake inputs, switch, then commit and push the new
  # flake.lock as "chore(flake): update inputs on <host>". On the Mac it also
  # runs brewup. Stops at the first failure and commits only after a good switch.
  # Before pulling it checks the internet and origin (Gitea, home network or VPN)
  # and waits for you to get online or connect the VPN.
  programs.fish.functions.fullUpdate = {
    description = "Pull, update flake inputs, switch, commit and push flake.lock${lib.optionalString isMacOS ", then brewup"}";
    body = ''
      cd ~/.nixcfg; or return 1

      # Only flake.lock should end up in the commit, so start from a clean tree
      if test -n "$(git status --porcelain)"
        echo "fullUpdate: ~/.nixcfg has uncommitted changes; commit or stash them first" >&2
        git status --short
        return 1
      end

      # Flake inputs need the internet; origin (Gitea) needs the home network or the VPN
      while true
        set -l problem
        if not curl -fs -o /dev/null --max-time 5 https://github.com
          set problem "no internet connection. Get online"
        else if not env GIT_SSH_COMMAND="ssh -o ConnectTimeout=5" git ls-remote -q origin HEAD >/dev/null 2>&1
          set problem "can't reach origin (Gitea). Connect the VPN"
        end
        test -z "$problem"; and break
        echo "fullUpdate: $problem" >&2
        read -l -P "Press Enter to try again, or q then Enter to quit: " answer; or return 1
        test "$answer" = q; and return 1
      end

      echo "==> git pull"
      git pull; or return 1

      echo "==> nix flake update"
      nix flake update; or return 1

      echo "==> switch ${hostname}"
      if not ${rebuild} switch --flake .#${hostname}
        echo "fullUpdate: switch failed, nothing committed. Undo the update with: git restore flake.lock" >&2
        return 1
      end

      if git diff --quiet -- flake.lock
        echo "==> inputs already current, nothing to commit"
      else
        echo "==> commit and push flake.lock"
        git commit -m "chore(flake): update inputs on ${hostname}" -- flake.lock; or return 1
        git push; or return 1
      end
    '' + lib.optionalString isMacOS ''

      echo "==> brewup"
      brew update; and brew upgrade; and brew cleanup
    '';
  };

  # prefwatch (Mac): find what a System Settings or app setting writes.
  # Run it once before changing ONE setting, change it, run it again: the
  # second run prints the changed keys and the Nix line to declare them.
  # "prefwatch reset" throws away a snapshot you no longer need.
  programs.fish.functions.prefwatch = lib.mkIf isMacOS {
    description = "Run before and after changing one macOS setting; prints the Nix line for it";
    body = ''
      set -l dir (set -q TMPDIR; and echo $TMPDIR; or echo /tmp)/defaults-watch
      if test "$argv[1]" = reset
        rm -rf $dir; and echo "prefwatch: snapshot cleared"
        return
      end
      # A snapshot older than an hour belongs to something else: start over
      if test -f $dir/before/stamp; and test (math (date +%s) - (/usr/bin/stat -f %m $dir/before/stamp)) -lt 3600
        bash ~/.nixcfg/scripts/defaults-watch.sh diff
        rm -rf $dir
        echo
        echo "prefwatch: done. Run prefwatch again before the next setting."
      else
        bash ~/.nixcfg/scripts/defaults-watch.sh snap; or return 1
        echo
        echo "prefwatch: now change ONE setting, close the pane or app, then run prefwatch again."
      end
    '';
  };

  # macaudit (Mac): inventory apps and settings nixcfg doesn't declare yet.
  # Options: --login-items, --containers, or an output folder.
  programs.fish.functions.macaudit = lib.mkIf isMacOS {
    description = "List Mac apps, settings and dotfiles that nixcfg doesn't declare yet";
    body = "bash ~/.nixcfg/scripts/mac-audit.sh $argv";
  };

  # x1audit (x1): the same inventory for NixOS/GNOME. Optional output folder.
  programs.fish.functions.x1audit = lib.mkIf (!isMacOS) {
    description = "List x1 GNOME settings, apps and dotfiles that nixcfg doesn't declare yet";
    body = "bash ~/.nixcfg/scripts/x1-audit.sh $argv";
  };

  # aiaudit (both): inventory AI clients, their config folders, MCP servers and
  # every skill under $HOME. Optional output folder.
  programs.fish.functions.aiaudit = {
    description = "List AI clients, their config and skills on this machine";
    body = "bash ~/.nixcfg/scripts/ai-audit.sh $argv";
  };
}
