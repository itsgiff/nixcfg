# ~/.nixcfg/modules/ai/claude-code.nix
# Claude Code on both machines: the same binary (sadjow/claude-code-nix) and
# the same user settings (~/.claude/settings.json, a read-only Home Manager
# link). Change user settings here, not in Claude Code: /config, /model and
# "always allow" at user level can't save. Per-project settings
# (.claude/settings.local.json) still work as usual.
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
  };
}
