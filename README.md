# NixOS & macOS Unified Configuration

A unified Nix configuration for my NixOS ThinkPad (x1) and macOS MacBook (macbook) using Flakes, Home Manager, and feature-based modules.

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
│   └── macbook/                # macOS MacBook
│       ├── configuration.nix   # Darwin configuration
│       └── Brewfile            # Homebrew packages (transitional)
├── modules/                    # Shared configuration modules
│   ├── features/               # Feature-based modules (shell, git, etc.)
│   ├── shared/                 # Shared between all systems
│   ├── nixos/                  # NixOS-specific modules
│   ├── darwin/                 # macOS-specific modules
│   └── home/                   # Home Manager specific modules
├── users/                      # User-specific configurations
│   └── paul/
│       └── home.nix            # Home Manager configuration
├── secrets/                    # Secret management (using sops-nix)
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

### macOS (macbook)

Build and activate the Darwin configuration:

```bash
cd ~/.nixcfg
darwin-rebuild switch --flake .#macbook
```

## Features

- **Cross-platform:** Unified configuration across NixOS and macOS
- **Modular design:** Feature-based modules for easy reuse and organization
- **Home Manager integration:** Consistent user environment across systems
- **Reproducible:** Pinned dependencies via Flakes
- **Transitional:** Homebrew/Mac App Store support for macOS-specific applications
- **Secure:** Secret management with encrypted files (using sops-nix)
- **AI-assisted:** Includes documentation and templates for AI assistants to help with configuration

## Project Management

- **Implementation Plan:** The `docs/plan.md` file contains a detailed, step-by-step guide for implementing the configuration across both systems
- **Progress Tracker:** The `docs/tracker.md` file provides a checklist to track implementation progress through each phase of the project

## Requirements

- NixOS or Nix with flakes enabled
- For macOS: nix-darwin
- Git for version control

## Getting Started

See the `docs/` directory for setup instructions and documentation.

## AI Integration

The `.ai/` directory contains instructions, context documents, and templates for various AI assistants used with this project:

- **claude/**: Claude-specific project knowledge and templates
- **chatgpt/**: ChatGPT custom instructions and templates
- **gemini/**: Gemini context information and templates
- **shared/**: Common resources usable across all AI platforms

These resources help maintain consistency when using AI assistants to work with this configuration.

## License

This configuration is released under the MIT License. See [LICENSE](LICENSE) for details.