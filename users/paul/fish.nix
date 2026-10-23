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
}
