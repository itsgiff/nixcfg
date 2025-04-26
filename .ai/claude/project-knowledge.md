# NixOS/macOS Unified Configuration Project

## Project Overview
- Creating a unified Nix configuration for NixOS ThinkPad (x1) and macOS MacBook (macbook)
- Using Nix Flakes, Home Manager, and feature-based modules
- Including transitional Homebrew and mas support for macOS

## Key Technology Stack
- Nix/NixOS
- Nix Flakes
- Home Manager
- nix-darwin
- Git for version control
- Optionally: sops-nix for secrets

## Directory Structure
Primary structure:
~/.nixcfg/
├── .ai                         # Assistant documentation and prompt design
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Generated lock file
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
└── secrets/                    # Secret management (if using sops-nix)

## Gitea Repo 
- url: git@gitea:paul/nixcfg.git

## Development Process
0. init git repo and use for sync
1. Implement on primary machine (x1) first
2. Test thoroughly before committing
3. Integrate with secondary machine (macbook)
4. Refactor into feature modules
5. Iterate with continuous improvements

## Best Practices
- Use READMEs in key directories to document purpose and structure
- Keep files logically organized but not unnecessarily deep
- Create feature modules based on functionality, not technology
- Maintain cross-platform compatibility where possible
- Document OS-specific configurations clearly
- Use conditional configurations based on platform (isLinux/isDarwin)
- Commit frequently with descriptive messages following conventional commits
- Test changes incrementally on each platform

## Implementation Approach
- Start with minimal working configuration
- Progressively enhance and refactor
- Keep track of the directory structure regularly
- Document steps and decision points
- Build feature modules one at a time
- Test configurations on both systems after each significant change

## Project Phases
1. SETUP & NIXOS: Repository initialization and NixOS migration
2. MACOS: Darwin integration and basic Home Manager
3. REFACTOR: Feature modules, Homebrew integration, secrets

## File Responsibilities
- flake.nix: Input sources, system definitions, module inclusion
- configuration.nix: System-specific settings
- home.nix: User environment configuration
- Feature modules: Specific software/settings organized by function