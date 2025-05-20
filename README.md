# NixOS & macOS Unified Configuration

A unified Nix configuration for my Linux (x1, nuc) and macOS (macbook) systems using Flakes, Home Manager, and feature-based modules.

## Overview

This repository contains a reproducible, declarative configuration for my computing environments across both NixOS and macOS systems. It uses Nix Flakes to provide a unified, pinned dependency tree and structured outputs for system and user configurations.

## Current Status

- **NixOS (x1 & nuc)**: :white_check_mark: Fully configured and operational on NixOS 24.11
- **macOS (macbook)**: :white_check_mark: Successfully integrated with nix-darwin and operational
- **Home Manager**: :white_check_mark: Working for all users across all systems (paul on x1/macbook, admin on nuc)
- **Feature Modules**: :white_check_mark: Core modules implemented and tested across platforms
- **NFS Configuration**: :white_check_mark: Configured for shared storage access on NixOS systems
- **Docker Support**: :white_check_mark: Set up for nuc with NVIDIA support
- **Bootstrap Script**: :white_check_mark: `nixinit.sh` available for quickly setting up new machines

## Structure

```
~/.nixcfg/
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Generated lock file (pinned dependencies)
├── hosts/                      # Machine-specific configurations
│   ├── x1/                     # NixOS ThinkPad
│   │   ├── configuration.nix   # System configuration
│   │   └── hardware-configuration.nix
│   ├── nuc/                    # NixOS NUC
│   │   ├── configuration.nix   # System configuration
│   │   └── hardware-configuration.nix
│   └── macbook/                # macOS MacBook
│       ├── configuration.nix   # Darwin configuration
│       └── home.nix            # Host-specific home config
├── modules/                    # Shared configuration modules
│   ├── darwin/                 # macOS-specific modules
│   ├── nixos/                  # NixOS-specific modules
│   │   ├── docker.nix          # Docker configuration for NixOS
│   │   └── nfs.nix             # NFS configuration for NixOS
│   ├── fastfetch.nix           # fastfetch config
│   ├── git.nix                 # Git configuration
│   ├── nvidia.nix              # NVIDIA driver and container support
│   ├── ssh.nix                 # SSH configuration
│   └── vscode.nix              # VSCode configuration
├── scripts/                    # Utility scripts
│   └── nixinit.sh              # Bootstrap script for new machines
├── users/                      # User-specific configurations
│   ├── admin/                  # NUC admin user
│   │   ├── fish.nix            # Fish shell configuration for admin
│   │   └── home.nix            # Home Manager configuration
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
1. Prompt for the machine hostname (must be one of: x1, nuc, macbook)
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

#### NixOS (nuc)

Build and activate the system configuration:

```bash
cd ~/.nixcfg
sudo nixos-rebuild switch --flake .#nuc
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
home-manager switch --flake .#admin@nuc   # For NUC with admin user
```

## Features

- **Cross-platform:** Unified configuration across NixOS and macOS
- **Multi-user:** Supports different usernames across systems (paul on x1/macbook, admin on nuc)
- **Modular design:** Feature-based modules for easy reuse and organization
- **Home Manager integration:** Consistent user environment across systems
- **Reproducible:** Pinned dependencies via Flakes
- **Transitional:** Homebrew/Mac App Store support for macOS-specific applications (planned)
- **Unfree Package Support:** Configuration includes allowance for proprietary software like VSCode
- **NFS Integration:** Configured for seamless access to shared storage
- **Docker Support:** Full Docker configuration with NVIDIA support for containers
- **Bootstrap Script:** Easy setup for new machines with the nixinit.sh script

## Next Steps

- Implement Homebrew integration for macOS-specific applications
- Expand macOS system preferences configuration
- Implement secret management with sops-nix
- Add more application-specific configurations

## Requirements

- NixOS or Nix with flakes enabled
- For macOS: nix-darwin
- Git for version control

## Documentation

See the `docs/` directory for detailed implementation plans and progress tracking.

## License

This configuration is released under the MIT License.