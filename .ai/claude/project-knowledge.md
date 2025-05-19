# NixOS/macOS Unified Configuration Project

## Project Overview
- Creating a unified Nix configuration for NixOS hosts (x1, nuc) and macOS Macbook (macbook)
- Using Nix Flakes, Home Manager, and feature-based modules
- Including transitional Homebrew and mas support for macOS

## Current Status
- **NixOS hosts** (x1, nuc): ✅ Fully configured and operational on NixOS 24.11
- **macOS** (macbook): 🟡 Basic configuration started - system preferences and dock settings configured
- **Feature modules**: 🟡 Core modules implemented (git, fish, vscode, fastfetch, etc.)
- **Home Manager**: ✅ Working for both paul (x1) and admin (nuc) users
- **Secret management**: 🔴 Not yet implemented

## Key Technology Stack
- Nix/NixOS (24.11)
- Nix Flakes
- Home Manager
- nix-darwin
- Git for version control
- Optionally: sops-nix for secrets (planned)

## Directory Structure
Current structure:
~/.nixcfg/
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Generated lock file
├── hosts/                      # Machine-specific configurations
│   ├── x1/                     # NixOS ThinkPad
│   │   ├── configuration.nix   # System configuration
│   │   └── hardware-configuration.nix
│   │   └── home.nix            # Host-specific home config (optional)
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
├── README.md                   # Project overview and usage instructions
└── docs/                       # Project documentation
    ├── plan.md                 # Detailed implementation plan
    └── tracker.md              # Project progress tracker

## Project Management
- Implementation Plan (docs/plan.md): Detailed step-by-step guide with current status
- Progress Tracker (docs/tracker.md): Checklist tracking progress through each phase

## Gitea Repo 
- url: git@gitea:paul/nixcfg.git

## Development Process
1. ✅ Initialize git repo and use for sync
2. ✅ Implement on primary machine (x1) first
3. ✅ Test thoroughly before committing
4. ✅ Integrate with additional machine (nuc)
5. ⏳ Integrate with macbook (in progress)
6. 🟡 Refactor into feature modules (ongoing)
7. ⏳ Iterate with continuous improvements

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
1. SETUP & NIXOS: ✅ Repository initialization and NixOS migration (COMPLETE)
2. MACOS: 🟡 Darwin integration and basic Home Manager (IN PROGRESS)
3. REFACTOR: 🔜 Feature modules, Homebrew integration, secrets (PLANNED)

## Feature Module Status
| Module | Linux | macOS | Notes |
|--------|-------|-------|-------|
| git.nix | ✅ | 🟡 | Working on Linux, needs testing on macOS |
| fish.nix | ✅ | 🟡 | Working on Linux, needs testing on macOS |
| vscode.nix | ✅ | 🟡 | Working on Linux, needs testing on macOS |
| fastfetch.nix | ✅ | 🟡 | Working on Linux, needs testing on macOS |
| ssh.nix | ✅ | 🔜 | Working on Linux, not yet configured for macOS |
| docker.nix | ✅ | N/A | Working on nuc, not relevant for macOS |
| nfs.nix | ✅ | 🔜 | Working on Linux, equivalent needed for macOS |
| nvidia.nix | ✅ | N/A | Working on nuc, not relevant for macOS |

## Next Actions
1. Complete macOS/nix-darwin configuration
2. Test Home Manager modules on macOS
3. Refine feature modules for better cross-platform compatibility
4. Implement Homebrew integration for macOS-specific applications
5. Set up secret management with sops-nix
6. Add more application-specific configurations

## File Responsibilities
- flake.nix: Input sources, system definitions, module inclusion
- configuration.nix: System-specific settings
- home.nix: User environment configuration
- Feature modules: Specific software/settings organized by function
- docs/plan.md: Detailed implementation steps for each phase
- docs/tracker.md: Checklist to track completion status of each step