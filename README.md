# NixOS & macOS Unified Configuration

A unified Nix configuration for my Linux (x1, nuc) and macOS (macbook) systems using Flakes, Home Manager, and feature-based modules.

## Overview

This repository contains a reproducible, declarative configuration for my computing environments across both NixOS and macOS systems. It uses Nix Flakes to provide a unified, pinned dependency tree and structured outputs for system and user configurations.

## Structure

```
~/.nixcfg/
├── .ai                         # Assistant documentation and prompt design
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
│       └── home.nix            # Optional host-specific home config
├── modules/                    # Shared configuration modules
│   ├── darwin/                 # macOS-specific modules
│   ├── fastfetch.nix           # fastfetch config
│   ├── fish.nix                # Fish shell configuration
│   ├── git.nix                 # Git configuration
│   ├── nixos/                  # NixOS-specific modules
│   │   └── nfs.nix             # NFS configuration for NixOS
│   └── vscode.nix              # VSCode configuration
├── users/                      # User-specific configurations
│   ├── admin/                  # NUC admin user
│   │   └── home.nix            # Home Manager configuration
│   └── paul/                   # Main user for x1 and macbook
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
home-manager switch --flake .#paul@x1    # For ThinkPad
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

## Project Management

- **Implementation Plan:** The `docs/plan.md` file contains a detailed, step-by-step guide for implementing the configuration across all systems
- **Progress Tracker:** The `docs/tracker.md` file provides a checklist to track implementation progress through each phase of the project

## Requirements

- NixOS or Nix with flakes enabled
- For macOS: nix-darwin
- Git for version control

## Getting Started

See the `docs/` directory for setup instructions and documentation.

## License

This configuration is released under the MIT License.
