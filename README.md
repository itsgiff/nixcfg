# NixOS & macOS Unified Configuration

A unified Nix configuration for my Linux (x1) and macOS (macbook) systems using Flakes, Home Manager, and feature-based modules.

## Overview

This repository contains a reproducible, declarative configuration for my computing environments across both NixOS and macOS systems. It uses Nix Flakes to provide a unified, pinned dependency tree and structured outputs for system and user configurations.

## Current Status

- **NixOS (x1 & nuc)**: ✅ Fully configured and operational on NixOS 24.11
- **macOS (macbook)**: ✅ Successfully integrated with nix-darwin and operational
- **Home Manager**: ✅ Working for all users across all systems (paul on x1/macbook, admin on nuc)
- **Feature Modules**: ✅ Core modules implemented and tested across platforms
- **NFS Configuration**: ✅ Configured for shared storage access on NixOS systems
- **Bootstrap Script**: ✅ `nixinit.sh` available for quickly setting up new machines
- **Secret Management**: 🔴 Not yet implemented

## Structure

```
~/.nixcfg/
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Generated lock file (pinned dependencies)
├── hosts/                      # Machine-specific configurations
│   ├── x1/                     # NixOS ThinkPad
│   │   ├── configuration.nix   # System configuration
│   │   └── hardware-configuration.nix
│   └── macbook/                # macOS MacBook
│       ├── configuration.nix   # Darwin configuration
│       └── home.nix            # Host-specific home config
├── modules/                    # Shared configuration modules
│   ├── darwin/                 # macOS-specific modules
│   │   ├── defaults.nix        # macOS system preferences
│   │   ├── desktop.nix         # macOS desktop environment
│   │   ├── homebrew.nix        # Homebrew integration
│   │   └── README.md           # macOS modules documentation
│   ├── nixos/                  # NixOS-specific modules
│   │   └── nfs.nix             # NFS configuration for NixOS
│   ├── fastfetch.nix           # fastfetch config
│   ├── fish.nix                # Fish shell configuration
│   ├── git.nix                 # Git configuration
│   ├── ssh.nix                 # SSH configuration
│   └── vscode.nix              # VSCode configuration
├── scripts/                    # Utility scripts
│   ├── nixinit.sh              # Bootstrap script for new machines
│   └── README.md               # Scripts documentation
├── users/                      # User-specific configurations
│   └── paul/                   # Main user for x1 and macbook
│       ├── fish.nix            # Fish shell configuration for paul
│       └── home.nix            # Home Manager configuration
├── README.md                   # This file
└── docs/                       # Project documentation
    ├── plan.md                 # Detailed implementation plan
    └── tracker.md              # Project progress tracker
```

## Getting Started

### Bootstrap a New Machine

To quickly set up a new machine with this configuration:

```bash
# For fresh NixOS installations:
wget -O- https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash

# If curl is available (e.g., on macOS):
curl -L https://raw.githubusercontent.com/itsgiff/nixcfg/main/scripts/nixinit.sh | bash
```

The script will:
1. Prompt for the machine hostname (must be one of: x1, macbook)
2. Set up the basic configuration and install git (for NixOS)
3. Clone the nixcfg repository
4. Enable experimental features for flakes
5. Apply the flake configuration
6. Optionally set up fish shell enhancements

### Manual Usage

#### NixOS (x1)

Build and activate the system configuration:

```bash
cd ~/.nixcfg
sudo nixos-rebuild switch --flake .#x1
```

#### macOS (macbook)

Build and activate the Darwin configuration:

```bash
cd ~/.nixcfg
darwin-rebuild switch --flake .#macbook
```

### Standalone Home Manager

You can also use Home Manager standalone if needed:

```bash
cd ~/.nixcfg
home-manager switch --flake .#paul@x1     # For ThinkPad
home-manager switch --flake .#paul@macbook  # For MacBook
```

## Features

- **Cross-platform:** Unified configuration across NixOS and macOS
- **Multi-user:** Supports different usernames across systems (paul on x1/macbook, admin on nuc)
- **Modular design:** Feature-based modules for easy reuse and organization
- **Home Manager integration:** Consistent user environment across systems
- **Reproducible:** Pinned dependencies via Flakes
- **Transitional:** Homebrew/Mac App Store support for macOS-specific applications
- **Unfree Package Support:** Configuration includes allowance for proprietary software like VSCode
- **NFS Integration:** Configured for seamless access to shared storage
- **Bootstrap Script:** Easy setup for new machines with the nixinit.sh script

## Next Steps

1. Refine feature modules for better cross-platform compatibility
2. Finalize Homebrew integration for macOS-specific applications
3. Set up Mac App Store integration for macOS
4. Implement secret management with sops-nix
5. Add more application-specific configurations
6. Document system management workflows

## Requirements

- NixOS or Nix with flakes enabled
- For macOS: nix-darwin
- Git for version control

## Documentation

See the `docs/` directory for detailed implementation plans and progress tracking.

## License

This configuration is released under the MIT License.