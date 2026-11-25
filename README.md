# nixcfg

Declarative Nix configuration for my two machines, built from one flake with Home Manager and shared modules.

| Host | Machine | System | Platform |
|---|---|---|---|
| `x1` | Lenovo ThinkPad X1 Carbon Gen 11 | NixOS 26.05, GNOME | `x86_64-linux` |
| `macbook` | MacBook | nix-darwin 26.05 on Determinate Nix | `aarch64-darwin` |

User `paul` on both, with fish as the login shell.

## Repository

- **origin is Gitea** on the home network: `gitea:paul/nixcfg.git`. The `gitea` SSH alias is defined in `modules/ssh.nix`. Connect the VPN before pulling or pushing from outside the home network.
- **GitHub (`itsgiff/nixcfg`) is a public, read-only mirror.** Gitea pushes every commit to it within seconds. Don't push to GitHub directly.
- The local clone lives at `~/.nixcfg` on both machines.

## Structure

```
~/.nixcfg/
├── flake.nix                     # Inputs and the two system outputs
├── flake.lock                    # Pinned input revisions
├── hosts/
│   ├── x1/
│   │   ├── configuration.nix     # NixOS system config
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix              # x1-only Home Manager: web-app launchers, Files bookmarks, default apps, Yogurt update check
│   │   ├── gnome.nix             # GNOME settings (dconf): dash, power, keyboard, touchpad, extensions
│   │   ├── wallpaper.jpg         # Desktop and lock-screen wallpaper (used by gnome.nix)
│   │   ├── yogurt.nix            # Yogurt meeting notes, packaged from its release AppImage
│   │   └── icons/                # Launcher icons: notion.png, perplexity.svg, chatgpt.svg
│   └── macbook/
│       ├── configuration.nix     # nix-darwin system config
│       └── home.nix              # Mac-only Home Manager (python3)
├── modules/
│   ├── ai/                       # AI clients, shared by both hosts (Home Manager):
│   │   └── claude-code.nix       #   Claude Code package, user settings and plugins
│   ├── darwin/                   # macOS system modules (see modules/darwin/README.md)
│   │   ├── defaults.nix          #   System Settings: Dock, Finder, keyboard, trackpad
│   │   ├── desktop.nix           #   Environment variables
│   │   └── homebrew.nix          #   Homebrew brews, casks, App Store apps, PATH
│   ├── nixos/
│   │   └── nfs.nix               # NFS automounts from the Synology (10.10.1.50)
│   ├── fastfetch.nix             # Home Manager modules, shared by both hosts:
│   ├── fish.nix                  #   fish settings and the nix* aliases
│   ├── git.nix                   #   git identity, aliases and settings
│   ├── ssh.nix                   #   SSH client hosts (machines these laptops connect to)
│   └── vscode.nix                #   VS Code extensions and settings
├── scripts/
│   ├── nixinit.sh                # Bootstrap for a new machine (see scripts/README.md)
│   ├── mac-audit.sh              # Mac: list apps and settings nixcfg doesn't declare yet
│   ├── defaults-watch.sh         # Mac: find the defaults key a settings toggle writes
│   ├── x1-audit.sh               # x1: list GNOME settings, apps and dotfiles nixcfg doesn't declare yet
│   ├── ai-audit.sh               # Both: list AI clients, their config folders, MCP servers and skills
│   └── README.md
└── users/paul/
    ├── home.nix                  # Shared Home Manager config; imports hosts/<host>/home.nix
    └── fish.nix                  # User aliases and the fullUpdate, prefwatch, macaudit, x1audit and aiaudit functions
```

## How it fits together

- **Inputs:** nixpkgs `nixos-26.05`, home-manager `release-26.05`, nix-darwin `nix-darwin-26.05`, `claude-code-nix` (Claude Code on both machines, installed by `modules/ai/claude-code.nix`), the Claude Code plugin sources `claude-plugins-official`, `knowledge-work-plugins` and `superpowers` (plain sources, `flake = false`) and `claude-desktop` (Claude Desktop on the x1).
- **Outputs:** `nixosConfigurations.x1` and `darwinConfigurations.macbook`.
- **Home Manager is integrated**, not standalone. It runs as part of every system switch (`useGlobalPkgs`, `useUserPackages`). There is no `home-manager` command and no `homeConfigurations` output; rollbacks go through system generations.
- User packages land in `/etc/profiles/per-user/paul/bin`.
- `users/paul/home.nix` imports `hosts/<hostname>/home.nix` through the `hostname` special argument, so per-machine user settings live next to that machine's system config.
- If Home Manager finds an unmanaged file where it wants to write one (for example an old `~/.ssh/config`), it renames the old file to `<name>.hm-bak` instead of failing the switch. Look for `*.hm-bak` files after a switch that takes over a new file.

## Daily use

The fish aliases are defined in `modules/fish.nix` and `users/paul/fish.nix`, and work the same on both machines.

| Command | What it does |
|---|---|
| `nixSwitch` | Rebuild and switch this machine from `~/.nixcfg` (system and Home Manager) |
| `nixFlakeUpdate` | Update all flake inputs (`nix flake update`) without switching |
| `nixUpgrade` | Update all inputs, then switch (no commit) |
| `fullUpdate` | Pull, update all inputs, switch, then commit and push `flake.lock` as `chore(flake): update inputs on <host>`; on the Mac, then `brewup`. Needs a clean tree; first waits until the internet and origin are reachable (asks you to get online or connect the VPN); commits nothing if the switch fails |
| `nixClean` | Delete generations older than 2 days and collect garbage |
| `git pull` / `git up` | Sync with Gitea (both rebase) |
| `gcm "<type>(<scope>): <msg>"` | Commit with a conventional-commit message (`cmf` shows the format) |
| `brewup` | Mac: update and upgrade Homebrew packages (switches never do this) |
| `prefwatch` | Mac: run before and after changing one setting; prints the Nix line for it |
| `macaudit` / `x1audit` | List what this machine has that nixcfg doesn't declare yet (see `scripts/README.md`) |
| `aiaudit` | List AI clients (Claude Code, Codex, Claude Desktop, ChatGPT, Perplexity, …), their config and every skill on this machine |

### Making a change

1. `git pull`
2. Edit one thing.
3. `nixSwitch` and check the result.
4. `gcm "…"` (it stages edits to tracked files itself; `git add` new files first), then `git push`.
5. On the other machine: `git pull`, then `nixSwitch` if the change applies to it.

Keep it to one change per rebuild, so a failure points at a single cause. Update inputs (`nixFlakeUpdate`) as a commit of their own, so they're easy to roll back.

For a change that should alter nothing, build without switching and compare:

```bash
nixos-rebuild build --flake .#x1 && nix store diff-closures /run/current-system ./result
darwin-rebuild build --flake .#macbook && nix store diff-closures /run/current-system ./result
```

No output means the system is unchanged.

### Rolling back

- **NixOS:** pick an older generation in the boot menu, or `sudo nixos-rebuild switch --rollback`.
- **nix-darwin:** `sudo darwin-rebuild switch --rollback`.
- **Git:** `git restore <file>` before committing, `git revert <hash>` after.

## x1 notes

- **GNOME settings are declared** in `hosts/x1/gnome.nix`. A setting changed by hand in GNOME is put back on the next switch, so change it there instead. To find the key a toggle writes, run `dconf watch /`, change it, and read the printed key.
- **Default apps** (`xdg.mimeApps`) and **Files sidebar bookmarks** are declared in `hosts/x1/home.nix`; GNOME Settings and Files can't change them any more.
- **Yogurt** isn't in nixpkgs, so `hosts/x1/yogurt.nix` wraps its release AppImage. To update it, bump `version`, set `hash = lib.fakeHash`, build, and copy the real hash from the error. A weekly user timer (Monday mornings, `yogurt-update-check` in `hosts/x1/home.nix`) sends a GNOME notification when GitHub has a newer release; run it by hand with `systemctl --user start yogurt-update-check`.
- Notion, Perplexity, ChatGPT and WhatsApp run as Chrome `--app` windows with their own launchers and dock icons. Apps added with Chrome's "Install as app" stay managed by Chrome sync.
- The dash pins Google Chrome only, like the Mac Dock. Anything pinned by hand is removed on the next switch.
- New GNOME extensions only show up after a log out and back in; do that before `gnome-extensions enable`.

## macOS notes

- **Nix and Homebrew coexist.** Nix provides the system, the Home Manager environment and some CLI tools. Homebrew (`modules/darwin/homebrew.nix`) provides GUI apps (casks), Mac App Store apps and most CLI tools.
- **PATH order:** Nix profiles, then Homebrew, then macOS. `which -a <cmd>` shows every copy; the first one wins.
- **Homebrew `cleanup = "check"`:** a switch never removes anything, but it stops and lists any Homebrew package that isn't declared in `homebrew.nix`. Declare it or uninstall it, then switch again.
- Switches never update or upgrade Homebrew packages; run `brewup` when you want that.
- **The Dock pins Google Chrome only** (`persistent-apps` in `modules/darwin/defaults.nix`). Anything pinned by hand is removed on the next switch.
- Before changing a setting in System Settings or an app, run `prefwatch`, change one thing, then run `prefwatch` again to get the Nix line to declare it.

## Bootstrap a new machine

```bash
curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

The script accepts only `x1` or `macbook` as the hostname. On NixOS it clones the repo and applies the flake; on macOS it clones the repo and stops, because Determinate Nix and nix-darwin have to be installed first. See `scripts/README.md`.

## Leave alone

`system.stateVersion` (`"23.05"` on the x1, `4` on the Mac) and `home.stateVersion` (`"24.11"`) look out of date but are correct. They record the release each machine was first installed with, so state migrations stay compatible. Never bump them to match the current release.

## License

This configuration is released under the MIT License.
