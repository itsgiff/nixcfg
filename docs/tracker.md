# NixOS/macOS Configuration Project Tracker

```
Legend: [✓] Complete  [⏳] In Progress  [_] Not Started  [⨯] Blocked
```

## Phase 1: Setup & NixOS Migration (on x1)
- [✓] Initialize Repository
  - [✓] Create ~/.nixcfg directory
  - [✓] Initialize Git
  - [✓] Create .gitignore and README.md
  - [✓] Initial commit
  - [✓] Add Gitea remote
  - [✓] Push initial commit
- [⏳] Ensure Flakes Enabled (NixOS)
  - [⏳] Check configuration.nix for flakes
  - [_] Add if needed and apply
- [_] Create Initial flake.nix
  - [_] Define inputs (nixpkgs, home-manager, nix-darwin)
  - [_] Setup outputs with nixosConfigurations and darwinConfigurations
  - [_] Define mkSystem helper function
- [_] Create Directory Structure
  - [_] hosts/{x1,macbook}
  - [_] users/paul
  - [_] modules/{shared,nixos,darwin,home,features}
- [_] Migrate NixOS System Config
  - [_] Copy configuration.nix and hardware-configuration.nix
  - [_] Modify with new module structure
  - [_] Update user definition
- [_] Migrate Home Manager Config
  - [_] Copy existing home.nix
  - [_] Adapt for cross-platform use
  - [_] Add conditionals (isLinux/isDarwin)
- [_] Initial NixOS Build & Test
  - [_] Run nix flake check
  - [_] Run nixos-rebuild switch
  - [_] Fix any errors
- [_] Commit & Push NixOS Setup
  - [_] Generate flake.lock
  - [_] Commit changes
  - [_] Push to Gitea

## Phase 2: macOS Integration (on macbook)
- [_] Clone Repository
  - [_] Clone from Gitea to ~/.nixcfg
- [_] Ensure Nix Setup
  - [_] Verify Nix installation
  - [_] Enable flakes in nix.conf
  - [_] Restart Nix daemon if needed
- [_] Create Initial Darwin Config
  - [_] Create macbook/configuration.nix
  - [_] Set system.stateVersion
  - [_] Configure basic macOS settings
- [_] Initial macOS Build & Test
  - [_] Run nix flake check
  - [_] Build derivation
  - [_] Run darwin-rebuild switch
  - [_] Fix any errors
- [_] Test Home Manager on macOS
  - [_] Verify shared settings work
  - [_] Add macOS-specific settings
  - [_] Test rebuild with new settings
- [_] Commit & Push Basic macOS Setup
  - [_] Commit changes
  - [_] Push to Gitea

## Phase 3: Refactoring & Advanced Features
- [_] Refactor into Feature Modules
  - [_] Identify common configurations
  - [_] Create shell.nix module
  - [_] Create git.nix module
  - [_] Create editor.nix module
  - [_] Import modules in configurations
- [_] Homebrew/MAS Integration (macOS)
  - [_] Add homebrew block to configuration.nix
  - [_] Create Brewfile
  - [_] Test darwin-rebuild with Homebrew
- [_] Secrets Management
  - [_] Add sops-nix to flake.nix inputs
  - [_] Import sops module
  - [_] Configure keys and paths
  - [_] Create sample encrypted secret
  - [_] Test secret access
- [_] Documentation
  - [_] Add READMEs to key directories
  - [_] Document feature modules
  - [_] Create usage instructions
- [_] Final Testing
  - [_] Test complete setup on x1
  - [_] Test complete setup on macbook
  - [_] Verify cross-platform compatibility

## Future Enhancements
- [_] System Theme/Appearance Module
- [_] Development Environment Modules
- [_] Container/VM Configuration
- [_] System Maintenance Scripts
- [_] Backup Configuration