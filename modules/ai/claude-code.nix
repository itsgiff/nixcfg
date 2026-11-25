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
{ pkgs, inputs, ... }:

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
}
