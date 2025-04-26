# ~/.nixcfg/flake.nix
{
  description = "Unified Nix configurations for x1 (NixOS) and macbook (macOS)";

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
                home-manager.users.paul = import ./users/paul/home.nix;
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
                home-manager.users.paul = import ./users/paul/home.nix;
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