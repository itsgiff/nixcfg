# Nix Configuration Implementation Plan

This plan outlines the steps to create a unified Nix configuration for the NixOS ThinkPad (x1) and macOS MacBook (macbook).

## Phase 1: Setup & NixOS Migration (Perform on `x1`)

1.  **Initialize Repository:**
    * Open a terminal on `x1`.
    * Create the directory: `mkdir -p ~/.nixcfg`
    * Navigate into it: `cd ~/.nixcfg`
    * Initialize Git: `git init`
    * Create essential Git files
    * Initial commit: `git add .gitignore README.md && git commit -m "Initial commit"`
    * Add your Gitea remote: `git remote add origin git@gitea:paul/nixcfg.git`
    * Push initial commit: `git push -u origin main` (or `master`)

2.  **Ensure Flakes Enabled (NixOS):**
    * Check if Flakes are enabled (likely on NixOS 25.05pre). Ensure the following line exists in `/etc/nixos/configuration.nix` under the `nix` attribute set, or add it:
        ```nix
        # /etc/nixos/configuration.nix
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        ```
    * If added, run `sudo nixos-rebuild switch` using your *old* configuration to apply the setting.

3.  **Create Initial `flake.nix`:**
    * Create the file `~/.nixcfg/flake.nix` with the following content (replace `your_username`):
        ```nix
        # ~/.nixcfg/flake.nix
        {
          description = "My unified Nix configurations for x1 (NixOS) and macbook (macOS)";

          inputs = {
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

            home-manager = {
              url = "github:nix-community/home-manager";
              inputs.nixpkgs.follows = "nixpkgs";
            };

            nix-darwin = {
              url = "github:LnL7/nix-darwin";
              inputs.nixpkgs.follows = "nixpkgs";
            };
            # Add sops-nix or agenix later if needed
          };

          outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
            let
              systems = {
                x1 = { hostname = "x1"; system = "x86_64-linux"; };
                macbook = { hostname = "macbook"; system = "aarch64-darwin"; };
              };

              mkSystem = { hostname, system, pkgs, modules }:
                if pkgs.stdenv.isLinux then
                  nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit inputs hostname; };
                    modules = modules ++ [
                      home-manager.nixosModules.home-manager
                      {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.your_username = import ./users/your_username/home.nix;
                      }
                    ];
                  }
                else if pkgs.stdenv.isDarwin then
                  nix-darwin.lib.darwinSystem {
                    inherit system;
                    specialArgs = { inherit inputs hostname; };
                    modules = modules ++ [
                      home-manager.darwinModules.home-manager
                      {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.your_username = import ./users/your_username/home.nix;
                      }
                    ];
                  };

            in {
              nixosConfigurations.x1 = mkSystem {
                hostname = systems.x1.hostname;
                system = systems.x1.system;
                pkgs = nixpkgs.legacyPackages.${systems.x1.system};
                modules = [ ./hosts/x1/configuration.nix ];
              };

              darwinConfigurations.macbook = mkSystem {
                hostname = systems.macbook.hostname;
                system = systems.macbook.system;
                pkgs = nixpkgs.legacyPackages.${systems.macbook.system};
                modules = [ ./hosts/macbook/configuration.nix ];
              };
            };
        }
        ```

4.  **Create Directory Structure:**
    ```bash
    cd ~/.nixcfg
    mkdir -p hosts/x1 hosts/macbook users/your_username modules/{shared,nixos,darwin,home,features}
    touch hosts/macbook/configuration.nix
    ```

5.  **Migrate NixOS System Config (`x1`):**
    * Copy existing files:
        ```bash
        cp /etc/nixos/configuration.nix ~/.nixcfg/hosts/x1/configuration.nix
        cp /etc/nixos/hardware-configuration.nix ~/.nixcfg/hosts/x1/hardware-configuration.nix
        ```
    * Edit `~/.nixcfg/hosts/x1/configuration.nix`:
        * Add header: `{ config, pkgs, lib, inputs, hostname, ... }:`.
        * Add imports: `imports = [ ./hardware-configuration.nix /* other modules later */ ];`.
        * Verify `networking.hostName = "x1";`.
        * Check `system.stateVersion`.
        * Update `users.users.your_username` block, removing direct Home Manager config.

6.  **Migrate Home Manager Config (`x1`):**
    * Copy existing config: `cp ~/.config/home-manager/home.nix ~/.nixcfg/users/your_username/home.nix`
    * Edit `~/.nixcfg/users/your_username/home.nix`:
        * Add header: `{ config, pkgs, lib, inputs, hostname, ... }:`.
        * Set Basic Info (Adapt for OS): `home.username`, `home.homeDirectory = if pkgs.stdenv.isLinux then "/home/${config.home.username}" else "/Users/${config.home.username}";`, `home.stateVersion`.
        * Review and wrap Linux-specific settings: `lib.mkIf pkgs.stdenv.isLinux { ... }`. Add placeholders for Darwin: `lib.mkIf pkgs.stdenv.isDarwin { /* macOS settings later */ }`.

7.  **Initial NixOS Build & Test (`x1`):**
    * `cd ~/.nixcfg`
    * Check for errors: `nix flake check`
    * Build and switch: `sudo nixos-rebuild switch --flake .#x1`
    * Debug any errors.

8.  **Commit & Push NixOS Setup:**
    * Update lock file: `nix flake lock`
    * Stage changes: `git add .`
    * Commit: `git commit -m "feat(nixos): Initial migration for x1 host"`
    * Push: `git push`

## Phase 2: macOS Integration (Perform on `macbook`)

9.  **Clone Repository:**
    * Open a terminal on `macbook`.
    * `git clone git@gitea:paul/nixcfg.git ~/.nixcfg`
    * `cd ~/.nixcfg`

10. **Ensure Nix Setup:**
    * Verify Nix is installed (`nix --version`). Install if needed.
    * Ensure flakes are enabled in `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`: `experimental-features = nix-command flakes`.
    * Restart Nix daemon if necessary.

11. **Create Initial Darwin Config:**
    * Edit `~/.nixcfg/hosts/macbook/configuration.nix`:
        ```nix
        # ~/.nixcfg/hosts/macbook/configuration.nix
        { config, pkgs, lib, inputs, hostname, ... }:

        {
          imports = [ /* modules later */ ];
          system.stateVersion = 4;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          users.users.your_username = {
            home = "/Users/your_username";
            shell = pkgs.zsh; # Or your preferred shell
          };
          services.nix-daemon.enable = true;
          time.timeZone = "America/Vancouver"; # Set your time zone
        }
        ```

12. **Initial macOS Build & Test (`macbook`):**
    * `cd ~/.nixcfg`
    * Check flake: `nix flake check`
    * Build derivation first: `nix build .#darwinConfigurations.macbook.config.system.build.toplevel`
    * Apply configuration: `darwin-rebuild switch --flake .#macbook`
    * Debug any errors.

13. **Test Home Manager on macOS:**
    * Verify shared settings from `users/your_username/home.nix` are active (packages, aliases, etc.).
    * Add macOS-specific settings (`lib.mkIf pkgs.stdenv.isDarwin { ... }`) to `home.nix`, rebuild, and test.

14. **Commit & Push Basic macOS Setup:**
    * `cd ~/.nixcfg`
    * Stage changes: `git add .`
    * Commit: `git commit -m "feat(darwin): Initial setup for macbook host"`
    * Push: `git push`

## Phase 3: Refactoring & Advanced Features (Iterate on either machine)

15. **Refactor into Feature Modules:**
    * Identify common configurations (shell, git, editor, etc.).
    * Create files like `modules/features/shell.nix`, `modules/features/git.nix`.
    * Move relevant Nix options into these modules.
    * Import modules using `imports = [ ../../modules/features/shell.nix ];` in host or user configurations.

16. **Transitional Homebrew/MAS Integration (macOS):**
    * Edit `~/.nixcfg/hosts/macbook/configuration.nix`.
    * Add the `homebrew` block:
        ```nix
        { config, pkgs, lib, ... }: {
          # ... other settings ...
          homebrew = {
            enable = true;
            onActivation.cleanup = "uninstall"; # Or "zap" or "skip"
            taps = [ /* "homebrew/cask-fonts" */ ];
            brewfile = ./Brewfile; # Preferred method
          };
        }
        ```
    * Create `~/.nixcfg/hosts/macbook/Brewfile` and add packages/casks/mas apps needed transitionally.
    * Rebuild on macOS: `darwin-rebuild switch --flake .#macbook`.
    * Actively try to replace Brew/MAS items with Nix equivalents over time.

17. **Secrets Management (Example: `sops-nix`):**
    * Add `sops-nix` input to `flake.nix`.
    * Import `sops-nix` module in system configs (`nixosModules.sops` / `darwinModules.sops`).
    * Configure `sops` settings (keys, paths).
    * Create encrypted secrets files (e.g., `secrets/secrets.yaml`) using `sops`. **Commit these encrypted files.**
    * Reference secrets in Nix configs (e.g., `config.sops.secrets.api_token.path`).
    * Ensure **private decryption keys** are NOT committed and exist only on target machines. Add key files/plaintext secrets to `.gitignore`.

18. **Continuous Iteration:**
    * On either machine: Make changes -> Test (`nixos-rebuild switch` / `darwin-rebuild switch`) -> Commit (`git commit`) -> Push (`git push`).
    * On the other machine: Pull (`git pull`) -> Apply (`nixos-rebuild switch` / `darwin-rebuild switch`).

