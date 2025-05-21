# NixOS/macOS Unified Configuration Implementation Plan

This document outlines the step-by-step implementation plan for the unified configuration across NixOS and macOS systems.

## Current Status Overview

- ✅ NixOS configurations for x1 and nuc are complete and operational
- ✅ Home Manager configurations for paul and admin users are working
- ✅ Core feature modules implemented (git, fish, vscode, fastfetch, etc.)
- ✅ Specialized modules for NixOS are working (docker, nfs, nvidia)
- ✅ Bootstrap script (nixinit.sh) created for easy machine setup
- ✅ macOS/nix-darwin integration is complete and operational
- 🟡 Feature module refinement is ongoing
- 🔜 Secret management implementation planned

## Phase 1: SETUP & NIXOS ✅ COMPLETED

### Repository Initialization
- ✅ Create initial repository structure
- ✅ Set up basic flake.nix with inputs
- ✅ Initialize git repository
- ✅ Add LICENSE and README.md

### NixOS Configuration (x1)
- ✅ Create initial system configuration
- ✅ Set up Home Manager integration
- ✅ Configure system packages and services
- ✅ Test and validate core functionality
- ✅ Add user-specific configurations

### NixOS Configuration (nuc)
- ✅ Create system configuration with appropriate hardware settings
- ✅ Set up admin user with Home Manager
- ✅ Configure Docker with NVIDIA support
- ✅ Set up NFS mounts and SSH configuration
- ✅ Test and validate server functionality

### Bootstrap Script
- ✅ Create nixinit.sh bootstrap script
- ✅ Add hostname validation and configuration
- ✅ Add repository cloning and setup
- ✅ Add flake configuration application
- ✅ Test script functionality across different hosts

## Phase 2: MACOS INTEGRATION ✅ COMPLETED

### nix-darwin Setup
- ✅ Install nix-darwin on macOS
- ✅ Create basic configuration.nix for macOS
- ✅ Set up compatibility with NixOS 24.11
- ✅ Set up macOS-specific preferences

### Home Manager for macOS
- ✅ Configure Home Manager for paul@macbook
- ✅ Fix PATH issues for darwin-rebuild and home-manager
- ✅ Configure macOS-specific shell environment
- ✅ Test cross-platform Home Manager modules

### Integration Testing
- ✅ Test unified configuration across all systems
- ✅ Verify feature modules work on macOS
- ✅ Ensure smooth updates and rebuilds

## Phase 3: REFINEMENT 🟡 IN PROGRESS

### Feature Module Development
- ✅ Create initial modules for common applications (git, vscode, etc.)
- 🟡 Refine existing modules for better cross-platform compatibility
- 🟡 Add more application-specific configurations
- 🟡 Implement conditional configurations for different platforms

### Homebrew Integration
- ✅ Set up basic Homebrew module structure
- ✅ Configure initial Homebrew package list
- ✅ Set up Mac App Store (mas) integration scaffold
- 🔜 Finalize and optimize Homebrew/mas integration

### Secret Management
- 🔜 Set up sops-nix for encrypted secrets
- 🔜 Create secure SSH and GPG key configuration
- 🔜 Manage sensitive data safely across systems

## Implementation Details

### Bootstrap Script Implementation
1. ✅ Create scripts directory in repository
2. ✅ Develop nixinit.sh with the following features:
   - Hostname validation (x1, nuc, macbook only)
   - Configuration file backups
   - Git installation and repository cloning
   - Flake experimental features enablement
   - System configuration application
   - Special handling for the nuc's Docker setup
   - Optional fish shell enhancements
3. ✅ Create one-liner for easy script execution
4. ✅ Test script on different host types

### macOS Integration Steps
1. ✅ Install nix-darwin on macBook
2. ✅ Create initial configuration.nix for macbook (basic system preferences)
3. ✅ Add darwin configuration to flake.nix
4. ✅ Test initial darwin-rebuild switch
5. ✅ Configure Home Manager for paul@macbook
6. ✅ Ensure PATH integration for system commands
7. ✅ Test cross-platform modules
8. ✅ Create macOS modules (defaults.nix, desktop.nix, homebrew.nix)
9. ✅ Document macOS-specific modules

### Feature Module Roadmap
1. ✅ Review and refine existing modules (git, fish, vscode, fastfetch)
2. 🟡 Create platform-specific versions of any incompatible configurations
3. 🟡 Add additional application configurations:
   - Browser configurations (Firefox, Chrome)
   - Terminal emulators
   - Development environments
   - Media applications
4. 🟡 Implement conditional platform detection and configuration

### Secret Management Approach
1. 🔜 Install and configure sops-nix
2. 🔜 Create encrypted secrets directory
3. 🔜 Store SSH keys, API tokens, and other sensitive data
4. 🔜 Set up automatic decryption during system activation

## Next Actions
1. ✅ Complete macOS/nix-darwin configuration
2. ✅ Test Home Manager modules on macOS
3. 🟡 Refine feature modules for better cross-platform compatibility
4. 🟡 Finalize Homebrew integration for macOS
5. 🔜 Implement secret management
6. 🔜 Document system management workflows