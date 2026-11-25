# ~/.nixcfg/modules/ai/skills.nix
# Local skills, the same on both machines, for Claude Code (~/.claude/skills)
# and Codex (~/.codex/skills). Each skill is linked on its own, so the folders
# stay writable: Claude Code's account sync (skills/synced/) and Codex's
# built-in skills (skills/.system/) keep working next to these.
#
# Sources are pinned flake inputs; fullUpdate moves them. To add a skill,
# add its source as an input (flake = false) and its name below. Skills from
# your claude.ai account sync by themselves and don't belong here.
{ lib, inputs, ... }:

let
  # github:emilkowalski/skills (design and animation)
  emilkowalski = [
    "animate"
    "animate-expo"
    "animation-performance"
    "animation-vocabulary"
    "apple-design"
    "ask-emil"
    "ask-sonner"
    "break-ui"
    "choreograph"
    "emil-design-eng"
    "find-animation-opportunities"
    "gestures"
    "improve-animations"
    "learn-taste"
    "mobile-native"
    "pick-ui-library"
    "prototype"
    "remove-animations"
    "review-animations"
    "write-swift"
  ];

  skills = lib.genAttrs emilkowalski (name: "${inputs.emilkowalski-skills}/skills/${name}");
in
{
  programs.claude-code.skills = skills;

  # Codex runs inside the ChatGPT app, which writes ~/.codex/config.toml
  # itself: no package and no settings here, so Home Manager only adds skills.
  programs.codex = {
    enable = true;
    package = null;
    inherit skills;
  };
}
