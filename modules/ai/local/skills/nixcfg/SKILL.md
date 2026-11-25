---
name: nixcfg
description: Paul's nixcfg flake (~/.nixcfg) for the x1 (NixOS) and the macbook (nix-darwin), with Home Manager integrated. Use for any change, question or fault in that repo or in either machine's Nix setup — packages, Home Manager, Homebrew on the Mac, GNOME settings, fish aliases, Claude Code or Codex config in modules/ai, flake inputs, a failed nixSwitch. Covers the house rules (patch files only, never commit, switch or push), how to check a change, and the known gotchas.
---

# nixcfg

The repo is `~/.nixcfg` on both machines. Its READMEs are the source of truth
for layout and commands, so read them before planning a change:

- `README.md`: hosts, layout, inputs, daily commands, rollback, x1 and Mac notes
- `modules/ai/README.md`: recipes for MCP servers, skills, plugins, agents, commands
- `modules/darwin/README.md`, `scripts/README.md`: Mac modules and the audit scripts

Check which machine you're on (`hostname -s`: `x1` or the Mac) before you
suggest a command; `nixSwitch` and `nixos-rebuild`/`darwin-rebuild` differ by host.

## House rules

1. **Paul makes every change and every commit.** Never edit files in
   `~/.nixcfg`, never run `nixSwitch`, `nixUpgrade`, `fullUpdate`, `sudo`,
   `git commit`, `git push` or `nix flake update` there. Deliver a patch file
   (see "Making a patch").
2. **One change per patch and per rebuild**, so a failure points at one cause.
   Related edits that only work together are one change; anything else is a
   second patch. Flake input updates are always their own change.
3. **READMEs move with scope.** If the change adds, removes or renames a host,
   module, script, flake input, fish alias or function, skill, plugin, MCP
   server or workflow step, or changes how something is managed, the same patch
   updates every affected README (`README.md`, `modules/ai/README.md`,
   `modules/darwin/README.md`, `scripts/README.md`). If none needs a change,
   say so explicitly.
4. **No secrets in the repo.** It is mirrored publicly to GitHub
   (`itsgiff/nixcfg`) and everything lands in the Nix store. Secrets go in
   files outside the repo, e.g. `~/.config/mcp-secrets/<name>`.
5. **Leave the state versions alone:** `system.stateVersion` (`"23.05"` x1,
   `4` macbook) and `home.stateVersion` (`"24.11"`).
6. **Check option names against the pinned source**, not memory (see
   "Checking"). Say which source you checked.
7. Keep comments in the house style: a header comment with the file path and
   what the file is for; plain sentences saying why, not what.

## Making a patch

Work in a throwaway clone so Paul's tree is never touched:

```bash
cd ~/.nixcfg && git status --short          # tell Paul if it isn't clean
rm -rf /tmp/nixcfg-work && git clone -q ~/.nixcfg /tmp/nixcfg-work && cd /tmp/nixcfg-work
# … edit …
git add -A                                   # a flake only sees files git knows about
```

Check it there (next section), then write the patch, numbered if there are
several, and show Paul the diff:

```bash
mkdir -p /tmp/nixcfg-patches
git -C /tmp/nixcfg-work diff --cached > /tmp/nixcfg-patches/0001-<slug>.patch
```

Give Paul one copy-pasteable block, chained with `&&` so a failure stops
before the rebuild:

```fish
cd ~/.nixcfg && git pull && git apply --check /tmp/nixcfg-patches/0001-<slug>.patch && git apply /tmp/nixcfg-patches/0001-<slug>.patch && git add <new files> && nixSwitch
```

Leave out `git add` when the patch creates no files. Then, separately, after
he has checked the result, the exact commit and push line:

```fish
gcm "<type>(<scope>): <message>" && git push
```

`gcm` is his fish function: it checks the conventional-commit format and runs
`git commit -a` (tracked edits are staged; new files need the `git add` above).
Types: feat, fix, docs, style, refactor, perf, test, build, chore, ci, revert.
Scopes in use: `ai`, `x1`, `macbook`, `macOS`, `scripts`, `fish`, `flake`,
`apps`, `home`, `modules`. Add a note to connect the VPN first if he may be
away from home (origin is Gitea on the LAN). If the change applies to the
other machine too: `cd ~/.nixcfg && git pull && nixSwitch` there.

## Checking

Run these in `/tmp/nixcfg-work`; none needs sudo or changes the system.

- Syntax: `nix-instantiate --parse <file> >/dev/null` for each edited `.nix` file.
- Evaluate both hosts (works from either machine):

  ```bash
  nix eval --raw .#nixosConfigurations.x1.config.system.build.toplevel.drvPath
  nix eval --raw .#darwinConfigurations.macbook.system.drvPath
  ```

- Build the host you're on, and compare with what's running:

  ```bash
  nixos-rebuild build --flake .#x1 && nix store diff-closures /run/current-system ./result
  darwin-rebuild build --flake .#macbook && nix store diff-closures /run/current-system ./result
  ```

  For a change that should alter nothing, no output from `diff-closures` is the pass.
- Option names: the `nixos` MCP server (mcp-nixos) if it's available, then the
  pinned sources, which match `flake.lock` exactly:

  ```bash
  nix flake archive --json | jq -r '.inputs | to_entries[] | "\(.key) \(.value.path)"'
  rg -n 'skills = mkOption' "$(nix flake archive --json | jq -r '.inputs."home-manager".path')/modules/programs"
  ```

Report what you ran and what it showed. Paul's `nixSwitch` is the real test;
say what to look for after it.

## Known gotchas

- **`*.hm-bak`:** when Home Manager takes over a file that already exists, it
  renames the old one to `<name>.hm-bak` instead of failing. After such a
  switch: `find ~ -maxdepth 4 -name '*.hm-bak' 2>/dev/null`. An existing
  `.hm-bak` blocks the next takeover of that file.
- **New files must be tracked:** an untracked file is silently left out of the flake.
- **`nix why-depends … nixpkgs#pkg`** ignores the system's
  `permittedInsecurePackages`; search `nix-store -qR /run/current-system` instead.
- **GNOME on Wayland (x1)** only finds new extensions after a log out and in;
  do that before `gnome-extensions enable`. GNOME settings are declared in
  `hosts/x1/gnome.nix`, so a change made by hand is reverted on the next switch.
- **`gdm-greeter` UID warnings** during activation are harmless.
- **Mac Homebrew:** `cleanup = "check"` stops the switch on any package not in
  `modules/darwin/homebrew.nix`; declare it or uninstall it. Switches never
  upgrade Homebrew; `brewup` does. Formulae occasionally move to casks or taps.
- **Mac settings:** to find the defaults key a toggle writes, remind Paul to
  run `prefwatch`, change one setting, then `prefwatch` again.
- **`curl | bash` installers fail on NixOS** (hard-coded loader paths); use a
  nixpkgs package or `autoPatchelfHook`.
- **Claude Code:** `~/.claude/settings.json` is a read-only link, so `/config`,
  `/model` and `/plugin install` can't save. Change `modules/ai/claude-code.nix`.
  `~/.codex/config.toml` belongs to the ChatGPT app; nixcfg never writes it.
- **No `home-manager` command** and no `homeConfigurations`: Home Manager runs
  inside every system switch, and rollbacks go through system generations.

## Tracking

Every change is tracked in Notion: a task under the "nixcfg maintenance" task
in the nixcfg project, assigned to Paul Gifford, with a **Commits:** line at the
top linking each commit as `https://github.com/itsgiff/nixcfg/commit/<full hash>`.
If Notion tools are available, follow that; if not, remind Paul at the end.
Routine flake updates stay in git only.
