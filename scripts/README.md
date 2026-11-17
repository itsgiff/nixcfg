# NixCfg Init Script

This directory contains utility scripts for the nixcfg configuration.

## nixinit.sh

Bootstrap script to initialize a new machine with the nixcfg configuration.

### Usage on a fresh NixOS installation:
```bash
wget -O- https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

### If curl is available (e.g., on macOS):
```bash
curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

### Features:

- Validates hostname (must be one of: x1, macbook)
- Backs up original NixOS configuration files
- Ensures git is installed on NixOS systems
- Clones the nixcfg repository and sets up the gitea remote
- Enables nix flake experimental features
- Applies the flake configuration for the specified host
- Provides specialized handling for macOS
- Optionally installs fish shell enhancements

### Security Note:

For additional security, you can download the script first to inspect it before running:

```bash
# Download the script
wget https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh
# Review it
less nixinit.sh
# Make it executable
chmod +x nixinit.sh
# Run it
./nixinit.sh
```

## Quick reference (macbook)

| I want to… | Run |
|---|---|
| find what a setting I'm about to change writes | `prefwatch`, change ONE setting, `prefwatch` again |
| drop a half-finished prefwatch | `prefwatch reset` |
| list apps and settings nixcfg doesn't declare yet | `macaudit` (add `--login-items` for login items) |

`prefwatch` and `macaudit` are fish functions from `users/paul/fish.nix` that run the scripts below.

## mac-audit.sh (macbook)

Read-only inventory of what the Mac has that nixcfg doesn't declare: apps by
source (cask / App Store / Nix / pkg / manual, with cask suggestions), third-party
and Apple preference domains, Dock items, unmanaged dotfiles and `*.hm-bak`
leftovers, launchd jobs, fonts.

```bash
bash ~/.nixcfg/scripts/mac-audit.sh                 # report in ~/nixcfg-audit-<date>/
bash ~/.nixcfg/scripts/mac-audit.sh --login-items   # also login items (Automation prompt)
bash ~/.nixcfg/scripts/mac-audit.sh --containers    # also sandboxed apps' prefs (privacy prompt)
```

## defaults-watch.sh (macbook)

Finds which preference key a GUI toggle writes and prints a Nix snippet.

```bash
bash ~/.nixcfg/scripts/defaults-watch.sh snap   # then change ONE setting and close the pane
bash ~/.nixcfg/scripts/defaults-watch.sh diff
```

## x1-audit.sh (x1)

Read-only inventory of what the x1 has that nixcfg doesn't declare: dconf
settings grouped by area (keys Home Manager already declares are counted, not
listed; window sizes, last-used paths, history and timestamps are dropped),
apps outside the system config (Flatpak, `nix profile`, AppImages, loose
binaries, Chrome "Install as app" launchers), autostart entries, user systemd
units, GNOME extensions by source, user fonts, unmanaged dotfiles and
`*.hm-bak` leftovers. `dconf-new.nix` holds the undeclared keys as a
Home Manager snippet (via dconf2nix).

```bash
bash ~/.nixcfg/scripts/x1-audit.sh    # report in ~/nixcfg-audit-<date>/
```

To find what one GNOME toggle writes (the x1's `prefwatch`): run `dconf watch /`
in a terminal, change the setting, read the printed key and value, Ctrl-C.
