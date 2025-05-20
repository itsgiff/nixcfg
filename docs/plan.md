# NixOS/macOS Unified Configuration Implementation Plan

This document outlines the step-by-step implementation plan for the unified configuration across NixOS and macOS systems.

## Current Status Overview

- :white_check_mark: NixOS configurations for x1 and nuc are complete and operational
- :white_check_mark: Home Manager configurations for paul and admin users are working
- :white_check_mark: Core feature modules implemented (git, fish, vscode, fastfetch, etc.)
- :white_check_mark: Specialized modules for NixOS are working (docker, nfs, nvidia)
- :white_check_mark: Bootstrap script (nixinit.sh) created for easy machine setup
- :white_check_mark: macOS/nix-darwin integration is complete and operational
- :hourglass_flowing_sand: Feature module refinement is ongoing
- :soon: Secret management implementation planned

## Phase 1: SETUP & NIXOS :white_check_mark: COMPLETED

### Repository Initialization
- :white_check_mark: Create initial repository structure
- :white_check_mark: Set up basic flake.nix with inputs
- :white_check_mark: Initialize git repository
- :white_check_mark: Add LICENSE and README.md

### NixOS Configuration (x1)
- :white_check_mark: Create initial system configuration
- :white_check_mark: Set up Home Manager integration
- :white_check_mark: Configure system packages and services
- :white_check_mark: Test and validate core functionality
- :white_check_mark: Add user-specific configurations

### NixOS Configuration (nuc)
- :white_check_mark: Create system configuration with appropriate hardware settings
- :white_check_mark: Set up admin user with Home Manager
- :white_check_mark: Configure Docker with NVIDIA support
- :white_check_mark: Set up NFS mounts and SSH configuration
- :white_check_mark: Test and validate server functionality

### Bootstrap Script
- :white_check_mark: Create nixinit.sh bootstrap script
- :white_check_mark: Add hostname validation and configuration
- :white_check_mark: Add repository cloning and setup
- :white_check_mark: Add flake configuration application
- :white_check_mark: Test script functionality across different hosts

## Phase 2: MACOS INTEGRATION :white_check_mark: COMPLETED

### nix-darwin Setup
- :white_check_mark: Install nix-darwin on macOS
- :white_check_mark: Create basic configuration.nix for macOS
- :white_check_mark: Set up compatibility with NixOS 24.11
- :white_check_mark: Set up macOS-specific preferences

### Home Manager for macOS
- :white_check_mark: Configure Home Manager for paul@macbook
- :white_check_mark: Fix PATH issues for darwin-rebuild and home-manager
- :white_check_mark: Configure macOS-specific shell environment
- :white_check_mark: Test cross-platform Home Manager modules

### Integration Testing
- :white_check_mark: Test unified configuration across all systems
- :white_check_mark: Verify feature modules work on macOS
- :white_check_mark: Ensure smooth updates and rebuilds

## Phase 3: REFINEMENT :hourglass_flowing_sand: IN PROGRESS

### Feature Module Development
- :white_check_mark: Create initial modules for common applications (git, vscode, etc.)
- :hourglass_flowing_sand: Refine existing modules for better cross-platform compatibility
- :hourglass_flowing_sand: Add more application-specific configurations
- :hourglass_flowing_sand: Implement conditional configurations for different platforms

### Homebrew Integration
- :soon: Finalize Homebrew package selection for macOS
- :soon: Create proper integration between Nix and Homebrew packages
- :soon: Set up Mac App Store (mas) integration

### Secret Management
- :soon: Set up sops-nix for encrypted secrets
- :soon: Create secure SSH and GPG key configuration
- :soon: Manage sensitive data safely across systems

## Implementation Details

### Bootstrap Script Implementation
1. :white_check_mark: Create scripts directory in repository
2. :white_check_mark: Develop nixinit.sh with the following features:
   - Hostname validation (x1, nuc, macbook only)
   - Configuration file backups
   - Git installation and repository cloning
   - Flake experimental features enablement
   - System configuration application
   - Special handling for the nuc's Docker setup
   - Optional fish shell enhancements
3. :white_check_mark: Create one-liner for easy script execution
4. :white_check_mark: Test script on different host types

### macOS Integration Steps
1. :white_check_mark: Install nix-darwin on macBook
2. :white_check_mark: Create initial configuration.nix for macbook (basic system preferences)
3. :white_check_mark: Add darwin configuration to flake.nix
4. :white_check_mark: Test initial darwin-rebuild switch
5. :white_check_mark: Configure Home Manager for paul@macbook
6. :white_check_mark: Ensure PATH integration for system commands
7. :white_check_mark: Test cross-platform modules

### Feature Module Roadmap
1. :white_check_mark: Review and refine existing modules (git, fish, vscode, fastfetch)
2. :hourglass_flowing_sand: Create platform-specific versions of any incompatible configurations
3. :soon: Add additional application configurations:
   - Browser configurations (Firefox, Chrome)
   - Terminal emulators
   - Development environments
   - Media applications
4. :hourglass_flowing_sand: Implement conditional platform detection and configuration

### Secret Management Approach
1. :soon: Install and configure sops-nix
2. :soon: Create encrypted secrets directory
3. :soon: Store SSH keys, API tokens, and other sensitive data
4. :soon: Set up automatic decryption during system activation

## Next Actions
1. :white_check_mark: Complete macOS/nix-darwin configuration
2. :white_check_mark: Test Home Manager modules on macOS
3. :hourglass_flowing_sand: Refine feature modules for better cross-platform compatibility
4. :soon: Implement Homebrew integration for macOS
5. :soon: Implement secret management
6. :soon: Document system management workflows