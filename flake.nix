{
  description = "Unified Nix configurations for x1 (NixOS), macbook (macOS), and nuc (NixOS)";

  inputs = {
    # Use nixos-unstable for more predictable behavior during transition
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nixos-hardware, ... }@inputs:
    let
      x1System = "x86_64-linux";
      nucSystem = "x86_64-linux";
      macSystem = "aarch64-darwin";
    in {
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = x1System;
        specialArgs = { inherit inputs; hostname = "x1"; };
        modules = [
          ./hosts/x1/configuration.nix
          { nixpkgs.config.allowUnfree = true; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "x1"; };
            home-manager.users.paul = ./users/paul/home.nix;
          }
        ];
      };

      nixosConfigurations.nuc = nixpkgs.lib.nixosSystem {
        system = nucSystem;
        specialArgs = { inherit inputs; hostname = "nuc"; };
        modules = [
          ./hosts/nuc/configuration.nix
          nixos-hardware.nixosModules.common-cpu-intel
          { nixpkgs.config.allowUnfree = true; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "nuc"; };
            home-manager.users.admin = ./users/admin/home.nix;
          }
        ];
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        system = macSystem;
        specialArgs = { inherit inputs; hostname = "macbook"; };
        modules = [
          ./hosts/macbook/configuration.nix
          { nixpkgs.config.allowUnfree = true; }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "macbook"; };
            home-manager.users.paul = ./users/paul/home.nix;
          }
        ];
      };

      homeConfigurations."paul@x1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x1System};
        extraSpecialArgs = { inherit inputs; hostname = "x1"; };
        modules = [ ./users/paul/home.nix { nixpkgs.config.allowUnfree = true; } ];
      };

      homeConfigurations."admin@nuc" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${nucSystem};
        extraSpecialArgs = { inherit inputs; hostname = "nuc"; };
        modules = [ ./users/admin/home.nix { nixpkgs.config.allowUnfree = true; } ];
      };

      homeConfigurations."paul@macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${macSystem};
        extraSpecialArgs = { inherit inputs; hostname = "macbook"; };
        modules = [ ./users/paul/home.nix { nixpkgs.config.allowUnfree = true; } ];
      };
    };
}
