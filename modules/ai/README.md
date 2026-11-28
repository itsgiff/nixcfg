# modules/ai

Claude Code and the Codex CLI, set up the same way on both machines through Home Manager.
This page is the how-to: each recipe below says which file to edit and which
commands to run, to add or remove an MCP server, skill, plugin, agent or slash
command.

## What lives where

| Layer | What | Managed by |
|---|---|---|
| Account | claude.ai skills, connectors, projects and memory; ChatGPT/Codex plugins and connectors | The Claude and ChatGPT apps. They sync to every device by themselves, so they stay out of nixcfg |
| Machine | Claude Code (binary, settings, plugins, MCP servers, skills, agents, slash commands); Codex CLI and skills | This folder |
| Project | `.claude/settings.json`, `.mcp.json`, `CLAUDE.md` / `AGENTS.md`, project skills in `.claude/skills/` | Committed in that project's own repo |
| App state | `~/.claude.json`, sessions, history, sign-ins, `~/.codex/config.toml` | Never managed (the apps rewrite these) |

| File | What it declares |
|---|---|
| `claude-code.nix` | Claude Code package, user settings (`~/.claude/settings.json`) and plugins; on the Mac, keeps the sign-in link handler pointed at the installed Claude Code |
| `mcp.nix` | MCP servers for Claude Code |
| `skills.nix` | Codex CLI from pinned nixpkgs, plus skills from other people's repos for Claude Code and Codex |
| `local.nix` | Your own skills, agents and slash commands, read from `local/` |
| `local/` | The files themselves: `skills/<name>/SKILL.md`, `agents/<name>.md`, `commands/<name>.md`. Holds `skills/nixcfg/`, the house rules for working on this repo |

Plugins and MCP servers are passed by the `claude` command's wrapper
(`--plugin-dir`), so they apply to Claude Code started with `claude`. Claude
Desktop and claude.ai don't see them; they use your account's skills and
connectors.

The `codex` command comes from the pinned nixpkgs package on both machines.
Run `codex --version` after switching to verify it is on PATH. The ChatGPT app
continues to own `~/.codex/config.toml` and sign-in state.

## Every change, start to finish

```bash
cd ~/.nixcfg && git pull               # VPN first when away from home
# … make the edit from one of the recipes below …
git add -A modules/ai flake.nix        # new files must be tracked, or the flake ignores them
nix flake lock                         # only when you added or removed a flake input
nixSwitch
gcm "feat(ai): <what you added or removed>" && git push
```

Then on the other machine: `cd ~/.nixcfg && git pull && nixSwitch`.

Start a new `claude` session to pick up the change; Codex needs a new chat.
`nix flake lock` adds a new input to `flake.lock` (or drops a removed one)
without updating the others. If a switch fails, nothing has changed: fix the
file or `git restore` it.

## MCP servers (Claude Code)

MCP servers give Claude Code tools that reach outside it (GitHub, a database,
the NixOS option search). They're declared in `servers` in `mcp.nix`. Home
Manager writes them to `~/.config/mcp/mcp.json` and the `claude` wrapper loads
them. Codex isn't included: the ChatGPT app owns `~/.codex/config.toml`, so add
Codex MCP servers in the app.

### Add an MCP server

Pick the first kind that fits, and add a block inside `servers = { … };`:

1. **Packaged in nixpkgs** (best: pinned with the system, nothing fetched at
   run time). Search with `nix search nixpkgs mcp`, then (this one, `nixos`,
   is already declared: mcp-nixos for NixOS, Home Manager and nix-darwin options):

   ```nix
   nixos = {
     command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
   };
   ```

2. **Remote (HTTP) server**: just the URL. If it needs a sign-in, run `/mcp` in
   Claude Code and pick the server; the sign-in stays in Claude Code's own
   state, not in the repo.

   ```nix
   context7 = {
     url = "https://mcp.context7.com/mcp";
   };
   ```

3. **Only on npm**: run it with npx and pin the version, so both machines run
   the same one. npx servers also need `node` on PATH (`which node`).

   ```nix
   some-server = {
     command = "${pkgs.nodejs}/bin/npx";
     args = [ "-y" "some-mcp-server@1.2.3" ];
   };
   ```

The block's name (`nixos`, `context7`, …) is the name Claude Code shows. Then
the steps in "Every change", with `gcm "feat(ai): add <name> MCP server"`. In a
new `claude` session, `/mcp` lists it with its status.

### An MCP server that needs a token or key

Never write a secret in a `.nix` file: it ends up in the Nix store and on the
public GitHub mirror. Put it in a file on each machine instead (fish):

```fish
mkdir -p ~/.config/mcp-secrets && chmod 700 ~/.config/mcp-secrets
read -s -P 'Token: ' t; printf '%s' $t > ~/.config/mcp-secrets/github; set -e t
chmod 600 ~/.config/mcp-secrets/github
```

and point the server's variable at it. `secret "github"` in `mcp.nix` means
`~/.config/mcp-secrets/github` on whichever machine you're on:

```nix
github = {
  command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
  args = [ "stdio" ];
  env.GITHUB_PERSONAL_ACCESS_TOKEN.file = secret "github";
};
```

The file is read each time the server starts. Do the `mkdir`/`read` step on both
machines; without the file, that server fails to start but the others work.

### Remove an MCP server

Delete its block from `servers` (or comment it out to keep it for later), then
the steps in "Every change". If it had a secret, also
`rm ~/.config/mcp-secrets/<name>` on both machines.

### Only for one project

Put it in that repo's `.mcp.json` instead (`claude mcp add --scope project …`
from inside the repo writes it), and commit it there.

## Skills

A skill is a folder with a `SKILL.md`. Claude Code and Codex both get every
skill declared here, in `~/.claude/skills/<name>` and `~/.codex/skills/<name>`.
Those links are read-only: edit the source, then switch.

### Add a skill you write yourself

```bash
mkdir -p ~/.nixcfg/modules/ai/local/skills/my-skill
code ~/.nixcfg/modules/ai/local/skills/my-skill/SKILL.md
```

```markdown
---
name: my-skill
description: What it does and when to use it. The agent picks skills by this line, so be specific.
---

# My skill

The steps, rules or reference the agent should follow.
```

The folder name is the skill name (lowercase, hyphens). Scripts or reference
files the skill uses go in the same folder. The `skill-creator` plugin can write
a first draft: ask Claude Code for one, then move the folder here.

Then the steps in "Every change", with `gcm "feat(ai): add my-skill skill"`.

### Remove a skill you wrote

```bash
cd ~/.nixcfg && git rm -r modules/ai/local/skills/my-skill && nixSwitch && gcm "feat(ai): remove my-skill skill" && git push
```

### Add skills from someone else's repo

1. Find the repo and the folder that holds the skill folders (each with a
   `SKILL.md`), e.g. `github:owner/repo` with skills under `skills/`.
2. In `flake.nix`, next to `emilkowalski-skills`:

   ```nix
   owner-skills = {
     url = "github:owner/repo";
     flake = false;
   };
   ```

3. In `skills.nix`, add a list of the skills you want under the `emilkowalski`
   list, and merge it into `skills`:

   ```nix
   # github:owner/repo (what they're for)
   owner = [
     "skill-a"
     "skill-b"
   ];

   skills =
     lib.genAttrs emilkowalski (name: "${inputs.emilkowalski-skills}/skills/${name}")
     // lib.genAttrs owner (name: "${inputs.owner-skills}/skills/${name}");
   ```

   Change `skills/` to wherever that repo keeps them.
4. The steps in "Every change", including `nix flake lock`.

Skill names must be unique across all sources, including `local/skills/`.

### Remove skills from someone else's repo

Delete the names from their list in `skills.nix`. If none are left from that
repo, also remove the list, its `// lib.genAttrs …` line and the input in
`flake.nix`, then run the steps in "Every change", including `nix flake lock`.

### Update skills from someone else's repo

`fullUpdate` updates them along with everything else. Just one source:

```bash
cd ~/.nixcfg && nix flake update owner-skills && nixSwitch && gcm "chore(flake): update owner-skills" && git push
```

## Claude Code plugins

A plugin bundles skills, slash commands, agents, hooks and MCP servers. They're
listed in `plugins` in `claude-code.nix`. Don't use `/plugin install` or
`/plugin enable`: `settings.json` is read-only, and plugins installed that way
would exist on one machine only.

### Add a plugin

- **From a marketplace already in the flake** (`claude-plugins-official`,
  `knowledge-work-plugins`): browse
  [claude-plugins-official/plugins](https://github.com/anthropics/claude-plugins-official/tree/main/plugins)
  or [knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins),
  then add a line to `plugins`:

  ```nix
  "${inputs.claude-plugins-official}/plugins/<name>"
  "${inputs.knowledge-work-plugins}/<name>"
  ```

  Some entries in the official marketplace only point at another repo (its
  `.claude-plugin/marketplace.json` gives a GitHub `source`). Add those as their
  own input, like `superpowers`.
- **From any other repo:** add it as an input with `flake = false` and add
  `"${inputs.<input>}"` to `plugins`, or `"${inputs.<input>}/<subfolder>"` if the
  plugin (the folder with `.claude-plugin/plugin.json`) isn't at the top.

Then the steps in "Every change" (`nix flake lock` if you added an input), with
`gcm "feat(ai): add <name> plugin"`. In a new `claude` session, the plugin's
commands show up when you type `/`.

### Remove a plugin

Delete its line from `plugins`. If it was the last plugin from that input,
remove the input from `flake.nix` too. Then the steps in "Every change",
including `nix flake lock`.

## Your own agents and slash commands (Claude Code only)

Codex has no equivalent, so these go to Claude Code only.

### Add a subagent

`modules/ai/local/agents/<name>.md`:

```markdown
---
name: reviewer
description: When Claude should hand work to this agent.
tools: Read, Grep, Glob
---

The agent's instructions.
```

`tools` is optional (it gets every tool without it). After the switch it's in
`~/.claude/agents/` and in Claude Code's `/agents` list.

### Add a slash command

`modules/ai/local/commands/<name>.md` becomes `/<name>`:

```markdown
---
description: One line shown in the / menu.
---

What to do. $ARGUMENTS is replaced by whatever you type after the command.
```

### Remove either

```bash
cd ~/.nixcfg && git rm modules/ai/local/agents/<name>.md && nixSwitch && gcm "feat(ai): remove <name> agent" && git push
```

(`local/commands/` for a command.)

## Things that stay manual

- **claude.ai skills and connectors:** add or remove them in the Claude app.
  They sync to Claude Desktop, claude.ai and Claude Code by themselves (on the
  Mac, Claude Code keeps copies in `~/.claude/skills/synced/`). Don't put them here as well.
- **ChatGPT/Codex plugins and connectors:** the **Plugins** tab in the ChatGPT
  app. The app owns `~/.codex/config.toml`, so nixcfg never writes it.
- **Per-project setup:** commit it in that project's repo (`.claude/`,
  `.mcp.json`, `AGENTS.md`), not here.
- **Claude Desktop MCP servers:** Claude Desktop rewrites its own
  `claude_desktop_config.json`, so it isn't linked from here. Use your claude.ai
  connectors there.
- **MCP secrets:** the files in `~/.config/mcp-secrets/`, made by hand on each
  machine.

## Checking

- `aiaudit` on both machines lists every skill, plugin copy and config file; the
  same `content_sha` in both `skills.tsv` files means identical skills.
- `ls -l ~/.claude/skills ~/.codex/skills` shows which skills are Nix links.
- If a new agent, command or skill has the same name as a file you made by hand,
  Home Manager renames yours to `*.hm-bak`:
  `find ~/.claude ~/.codex -name '*.hm-bak'`.

## Undo

- Before committing: `git restore <file>` (or `git rm -r --cached` plus delete
  for a new file), then `nixSwitch`.
- After committing: `git revert HEAD && git push`, then `nixSwitch`.
- A bad switch: `sudo nixos-rebuild switch --rollback` (x1) or
  `sudo darwin-rebuild switch --rollback` (Mac).

You can also ask Claude Code or Codex to "add the X MCP server / skill / plugin to nixcfg":
it drafts the patch following this page. On either machine, the shared `nixcfg` skill
(`local/skills/nixcfg/SKILL.md`) gives the agent the house rules: it works in a clone in
`/tmp`, writes patch files to `~/Downloads/`, and never edits `~/.nixcfg`, switches,
commits or pushes. Update that skill when a rule here changes.
