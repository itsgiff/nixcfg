# ~/.nixcfg/modules/ai/local.nix
# Your own skills, agents and slash commands, written in this repo rather than
# pulled from someone else's (those are in skills.nix and claude-code.nix).
# Put the files in local/ and switch; modules/ai/README.md has the steps.
#
#   local/skills/<name>/SKILL.md   skill for Claude Code and Codex
#   local/agents/<name>.md         Claude Code subagent (~/.claude/agents)
#   local/commands/<name>.md       Claude Code slash command /<name> (~/.claude/commands)
#
# Folders that don't exist yet are simply skipped. git add new files before
# nixSwitch: a flake only sees files git knows about, so an untracked file
# is silently left out.
{ lib, ... }:

let
  dir = ./local;

  # Entries of local/<sub> of one type ("directory" or "regular"), or none
  # if the folder doesn't exist.
  entries = sub: type:
    let path = dir + "/${sub}"; in
    lib.optionalAttrs (builtins.pathExists path)
      (lib.filterAttrs (_: t: t == type) (builtins.readDir path));

  # local/skills/<name>/ -> { <name> = path; }
  skills = lib.mapAttrs (name: _: dir + "/skills/${name}") (entries "skills" "directory");

  # local/<sub>/<name>.md -> { <name> = path; } (README.md is skipped)
  markdown = sub:
    lib.mapAttrs'
      (file: _: lib.nameValuePair (lib.removeSuffix ".md" file) (dir + "/${sub}/${file}"))
      (lib.filterAttrs (file: _: lib.hasSuffix ".md" file && file != "README.md")
        (entries sub "regular"));
in
{
  programs.claude-code = {
    inherit skills;
    agents = markdown "agents";
    commands = markdown "commands";
  };

  # Codex has no agents or commands like Claude Code's; it gets the skills.
  programs.codex.skills = skills;
}
