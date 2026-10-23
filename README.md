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
│   │   ├── home.nix              # x1-only Home Manager (Notion web-app launcher)
│   │   └── icons/notion.png
│   └── macbook/
│       ├── configuration.nix     # nix-darwin system config
│       └── home.nix              # Mac-only Home Manager (Python env with garminconnect)
├── modules/
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
│   └── README.md
└── users/paul/
    ├── home.nix                  # Shared Home Manager config; imports hosts/<host>/home.nix
    └── fish.nix                  # User aliases (fullUpdate, brewup, ...)
```

## How it fits together

- **Inputs:** nixpkgs `nixos-26.05`, home-manager `release-26.05`, nix-darwin `nix-darwin-26.05`, `claude-code-nix` (Claude Code) and `claude-desktop` (Claude Desktop on the x1).
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
| `nixUpgrade` / `fullUpdate` | Update all inputs, then switch |
| `nixClean` | Delete generations older than 2 days and collect garbage |
| `git pull` / `git up` | Sync with Gitea (both rebase) |
| `gcm "<type>(<scope>): <msg>"` | Commit with a conventional-commit message (`cmf` shows the format) |
| `brewup` | Mac: update and upgrade Homebrew packages (switches never do this) |

### Making a change

1. `git pull`
2. Edit one thing.
3. `nixSwitch` and check the result.
4. `git add -u && gcm "…"`, then `git push`.
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

## macOS notes

- **Nix and Homebrew coexist.** Nix provides the system, the Home Manager environment and some CLI tools. Homebrew (`modules/darwin/homebrew.nix`) provides GUI apps (casks), Mac App Store apps and most CLI tools.
- **PATH order:** Nix profiles, then Homebrew, then macOS. `which -a <cmd>` shows every copy; the first one wins.
- **Homebrew `cleanup = "check"`:** a switch never removes anything, but it stops and lists any Homebrew package that isn't declared in `homebrew.nix`. Declare it or uninstall it, then switch again.
- Switches never update or upgrade Homebrew packages; run `brewup` when you want that.

## Bootstrap a new machine

```bash
curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

The script accepts only `x1` or `macbook` as the hostname. On NixOS it clones the repo and applies the flake; on macOS it clones the repo and stops, because Determinate Nix and nix-darwin have to be installed first. See `scripts/README.md`.

## Leave alone

`system.stateVersion` (`"23.05"` on the x1, `4` on the Mac) and `home.stateVersion` (`"24.11"`) look out of date but are correct. They record the release each machine was first installed with, so state migrations stay compatible. Never bump them to match the current release.

## License

This configuration is released under the MIT License.
