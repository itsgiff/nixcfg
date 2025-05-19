# NixOS & macOS Unified Configuration

A unified Nix configuration for my Linux (x1, nuc) and macOS (macbook) systems using Flakes, Home Manager, and feature-based modules.

## Overview

This repository contains a reproducible, declarative configuration for my computing environments across both NixOS and macOS systems. It uses Nix Flakes to provide a unified, pinned dependency tree and structured outputs for system and user configurations.

## Current Status

- **NixOS (x1 & nuc)**: ✅ Fully configured and operational on NixOS 24.11
- **macOS (macbook)**: 🟡 Basic configuration started - system preferences and dock settings configured
- **Home Manager**: ✅ Working for both paul (x1) and admin (nuc) users
- **Feature Modules**: ✅ Core modules implemented (git, fish, vscode, etc.)
- **NFS Configuration**: ✅ Configured for shared storage access
- **Docker Support**: ✅ Set up for nuc with NVIDIA support

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

## Usage

### NixOS (x1)

Build and activate the system configuration:

```bash
cd ~/.nixcfg
sudo nixos-rebuild switch --flake .#x1
```

### NixOS (nuc)

Build and activate the system configuration:

```bash
cd ~/.nixcfg
sudo nixos-rebuild switch --flake .#nuc
```

### macOS (macbook)

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
- **Transitional:** Homebrew/Mac App Store support for macOS-specific applications
- **Unfree Package Support:** Configuration includes allowance for proprietary software like VSCode
- **NFS Integration:** Configured for seamless access to shared storage
- **Docker Support:** Full Docker configuration with NVIDIA support for containers

## Next Steps

- Complete macOS/nix-darwin integration
- Refine feature modules and user configurations
- Implement secret management with sops-nix
- Add more application-specific configurations

## Requirements

- NixOS or Nix with flakes enabled
- For macOS: nix-darwin
- Git for version control

## Getting Started

See the `docs/` directory for setup instructions and detailed documentation.

## License

This configuration is released under the MIT License.