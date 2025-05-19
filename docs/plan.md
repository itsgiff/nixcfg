# NixOS/macOS Unified Configuration Implementation Plan

This document outlines the step-by-step implementation plan for the unified configuration across NixOS and macOS systems.

## Current Status Overview

- ✅ NixOS configurations for x1 and nuc are complete and operational
- ✅ Home Manager configurations for paul and admin users are working
- ✅ Core feature modules implemented (git, fish, vscode, fastfetch, etc.)
- ✅ Specialized modules for NixOS are working (docker, nfs, nvidia)
- ⏳ macOS/nix-darwin integration is in progress 
- ⏳ Feature module refinement is ongoing
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

## Phase 2: MACOS INTEGRATION 🟡 IN PROGRESS

### nix-darwin Setup
- ✅ Install nix-darwin on macOS
- ✅ Create basic configuration.nix for macOS
- ⏳ Configure Homebrew integration
- ⏳ Set up macOS-specific preferences

### Home Manager for macOS
- ⏳ Configure Home Manager for paul@macbook
- 🔜 Set up application preferences
- 🔜 Configure macOS-specific shell environment
- 🔜 Test cross-platform Home Manager modules

### Integration Testing
- 🔜 Test unified configuration across all systems
- 🔜 Verify feature modules work on macOS
- 🔜 Ensure smooth updates and rebuilds

## Phase 3: REFINEMENT 🔜 PLANNED

### Feature Module Development
- ✅ Create initial modules for common applications (git, vscode, etc.)
- 🔜 Refine existing modules for better cross-platform compatibility
- 🔜 Add more application-specific configurations
- 🔜 Implement conditional configurations for different platforms

### Homebrew Integration
- 🔜 Finalize Homebrew package selection for macOS
- 🔜 Create proper integration between Nix and Homebrew packages
- 🔜 Set up Mac App Store (mas) integration

### Secret Management
- 🔜 Set up sops-nix for encrypted secrets
- 🔜 Create secure SSH and GPG key configuration
- 🔜 Manage sensitive data safely across systems

## Implementation Details

### macOS Integration Steps
1. ✅ Install nix-darwin on macBook
2. ✅ Create initial configuration.nix for macbook (basic system preferences)
3. ✅ Add darwin configuration to flake.nix
4. ⏳ Test initial darwin-rebuild switch
5. 🔜 Set up Homebrew integration for macOS-specific applications
6. ⏳ Configure Home Manager for paul@macbook
7. 🔜 Test cross-platform modules

### Feature Module Roadmap
1. Review and refine existing modules (git, fish, vscode, fastfetch)
2. Create platform-specific versions of any incompatible configurations
3. Add additional application configurations:
   - Browser configurations (Firefox, Chrome)
   - Terminal emulators
   - Development environments
   - Media applications
4. Implement conditional platform detection and configuration

### Secret Management Approach
1. Install and configure sops-nix
2. Create encrypted secrets directory
3. Store SSH keys, API tokens, and other sensitive data
4. Set up automatic decryption during system activation

## Next Actions
1. Complete macOS/nix-darwin configuration
2. Test Home Manager modules on macOS
3. Refine feature modules for better cross-platform compatibility
4. Implement secret management
5. Document system management workflows