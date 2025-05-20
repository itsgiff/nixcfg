# NixOS/macOS Unified Configuration Project

## Project Overview
- Creating a unified Nix configuration for NixOS hosts (x1, nuc) and macOS Macbook (macbook)
- Using Nix Flakes, Home Manager, and feature-based modules
- Including transitional Homebrew and mas support for macOS

## Current Status
- **NixOS hosts** (x1, nuc): :white_check_mark: Fully configured and operational on NixOS 24.11
- **macOS** (macbook): :white_check_mark: Successfully integrated with nix-darwin and operational
- **Feature modules**: :yellow_circle: Core modules implemented and working across platforms
- **Home Manager**: :white_check_mark: Working for all users across all systems
- **Secret management**: :red_circle: Not yet implemented

## Key Technology Stack
- Nix/NixOS (24.11)
- Nix Flakes
- Home Manager
- nix-darwin
- Git for version control
- Optionally: sops-nix for secrets (planned)

## Directory Structure
Current structure:
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

## Project Management
- Implementation Plan (docs/plan.md): Detailed step-by-step guide with current status
- Progress Tracker (docs/tracker.md): Checklist tracking progress through each phase

## Gitea Repo 
- url: git@gitea:paul/nixcfg.git

## Development Process
1. :white_check_mark: Initialize git repo and use for sync
2. :white_check_mark: Implement on primary machine (x1) first
3. :white_check_mark: Test thoroughly before committing
4. :white_check_mark: Integrate with additional machine (nuc)
5. :white_check_mark: Integrate with macbook (complete)
6. :yellow_circle: Refactor into feature modules (ongoing)
7. :hourglass_flowing_sand: Iterate with continuous improvements

## Git Commit Conventions
All commits to this repository MUST follow the Conventional Commits specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: A new feature or enhancement
- **fix**: A bug fix
- **docs**: Documentation changes only
- **style**: Changes that don't affect code meaning (white-space, formatting)
- **refactor**: Code restructuring without feature changes
- **perf**: Performance improvements
- **test**: Test additions or modifications
- **chore**: Maintenance tasks, dependency updates
- **ci**: Changes to CI configuration

### Scopes
Common scopes for this project include:
- **core**: Base configuration
- **macOS**: macOS/darwin-specific changes
- **nixos**: NixOS-specific changes
- **fish**: Fish shell configuration
- **modules**: Feature modules changes
- **home**: Home-manager configurations
- **flake**: Changes to flake.nix

### Examples
- `feat(macOS): add homebrew integration`
- `fix(fish): resolve PATH issues on macOS`
- `docs: update status after macOS implementation`
- `refactor(modules): improve cross-platform compatibility`
- `chore: update flake inputs`

## Best Practices
- Use READMEs in key directories to document purpose and structure
- Keep files logically organized but not unnecessarily deep
- Create feature modules based on functionality, not technology
- Maintain cross-platform compatibility where possible
- Document OS-specific configurations clearly
- Use conditional configurations based on platform (isLinux/isDarwin)
- Commit frequently with descriptive messages following conventional commits
- Test changes incrementally on each platform
- Regularly update the tracker to reflect progress
- Follow the implementation plan for a structured approach

## Implementation Approach
- Start with minimal working configuration
- Progressively enhance and refactor
- Keep track of the directory structure regularly
- Document steps and decision points
- Build feature modules one at a time
- Test configurations on both systems after each significant change

## Project Phases
1. SETUP & NIXOS: :white_check_mark: Repository initialization and NixOS migration (COMPLETE)
2. MACOS: :white_check_mark: Darwin integration and Home Manager (COMPLETE)
3. REFACTOR: :hourglass_flowing_sand: Feature modules, Homebrew integration, secrets (IN PROGRESS)

## Feature Module Status
| Module | Linux | macOS | Notes |
|--------|-------|-------|-------|
| git.nix | :white_check_mark: | :white_check_mark: | Working on all platforms |
| fish.nix | :white_check_mark: | :white_check_mark: | Working with platform-specific features |
| vscode.nix | :white_check_mark: | :white_check_mark: | Working on all platforms |
| fastfetch.nix | :white_check_mark: | :white_check_mark: | Working on all platforms |
| ssh.nix | :white_check_mark: | :yellow_circle: | Working on Linux, partially on macOS |
| docker.nix | :white_check_mark: | N/A | Working on nuc, not relevant for macOS |
| nfs.nix | :white_check_mark: | :soon: | Working on Linux, equivalent needed for macOS |
| nvidia.nix | :white_check_mark: | N/A | Working on nuc, not relevant for macOS |

## Next Actions
1. Implement Homebrew integration for macOS-specific applications
2. Expand macOS system preferences configuration
3. Refine feature modules for better cross-platform compatibility
4. Set up secret management with sops-nix
5. Add more application-specific configurations

## File Responsibilities
- flake.nix: Input sources, system definitions, module inclusion
- configuration.nix: System-specific settings
- home.nix: User environment configuration
- Feature modules: Specific software/settings organized by function
- docs/plan.md: Detailed implementation steps for each phase
- docs/tracker.md: Checklist to track completion status of each step