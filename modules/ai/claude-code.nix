# ~/.nixcfg/modules/ai/claude-code.nix
# Claude Code on both machines: the same binary (sadjow/claude-code-nix) and
# the same user settings (~/.claude/settings.json, a read-only Home Manager
# link). Change user settings here, not in Claude Code: /config, /model and
# "always allow" at user level can't save. Per-project settings
# (.claude/settings.local.json) still work as usual.
#
# Plugins come from pinned flake inputs and load through the wrapper's
# --plugin-dir, so /plugin install and enable/disable don't apply to them:
# add or remove a plugin here.
#
# Mac sign-in links (claude-cli://) open ~/Applications/Claude Code URL
# Handler.app, which Claude Code creates with a link to the exact store path
# that first ran it. Claude Code doesn't update that link when it's upgraded,
# so it goes stale (and breaks once garbage collection removes that version).
# Every switch points it at the installed Claude Code and re-registers it.
{ config, lib, pkgs, inputs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      model = "opus";
      theme = "dark";
      tui = "fullscreen";
      agentPushNotifEnabled = true;
    };

    plugins = [
      "${inputs.claude-plugins-official}/plugins/code-review"
      "${inputs.claude-plugins-official}/plugins/frontend-design"
      "${inputs.claude-plugins-official}/plugins/skill-creator"
      "${inputs.claude-plugins-official}/plugins/claude-code-setup"
      "${inputs.claude-plugins-official}/plugins/claude-md-management"
      "${inputs.superpowers}"                     # obra/superpowers (listed in claude-plugins-official)
      "${inputs.knowledge-work-plugins}/sales"
    ];
  };

  home.activation.claudeCodeUrlHandler = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app="$HOME/Applications/Claude Code URL Handler.app"
      # Skipped until Claude Code has created the app (first sign-in)
      if [ -d "$app/Contents/MacOS" ]; then
        run ln -sfn ${lib.escapeShellArg "${config.programs.claude-code.package}/bin/.claude-unwrapped"} "$app/Contents/MacOS/claude"
        run /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
      fi
    ''
  );
}
