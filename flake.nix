{
  description = "Unified Nix configurations for x1 (NixOS), macbook (macOS), and nuc (NixOS)";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nixos-hardware, ... }@inputs:
    let
      systems = {
        x1 = { hostname = "x1"; system = "x86_64-linux"; username = "paul"; };
        macbook = { hostname = "macbook"; system = "aarch64-darwin"; username = "paul"; };
        nuc = { hostname = "nuc"; system = "x86_64-linux"; username = "admin"; };
      };
    in {
      # NixOS configuration for x1
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = systems.x1.system;
        specialArgs = { inherit inputs; hostname = systems.x1.hostname; };
        modules = [
          ./hosts/x1/configuration.nix
          { nixpkgs.config.allowUnfree = true; }          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = systems.x1.hostname; };
            home-manager.users.${systems.x1.username} = ./users/paul/home.nix;
          }
        ];
      };

      # NixOS configuration for nuc
      nixosConfigurations.nuc = nixpkgs.lib.nixosSystem {
        system = systems.nuc.system;
        specialArgs = { inherit inputs; hostname = systems.nuc.hostname; };
        modules = [
          ./hosts/nuc/configuration.nix
          nixos-hardware.nixosModules.common-cpu-intel
          # Add other hardware modules as needed
          { nixpkgs.config.allowUnfree = true; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = systems.nuc.hostname; };
            # Point to the correct home.nix file for admin user
            home-manager.users.${systems.nuc.username} = ./users/admin/home.nix;
          }
        ];
      };

      # Darwin configuration
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        system = systems.macbook.system;
        specialArgs = { inherit inputs; hostname = systems.macbook.hostname; };
        modules = [
          ./hosts/macbook/configuration.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = systems.macbook.hostname; };
            home-manager.users.${systems.macbook.username} = ./users/paul/home.nix;
          }
        ];
      };

      # Home Manager standalone configurations
      homeConfigurations."paul@x1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.x1.system};
        extraSpecialArgs = { inherit inputs; hostname = systems.x1.hostname; };
        modules = [
          ./users/paul/home.nix
          { nixpkgs.config.allowUnfree = true; }
        ];
      };

      homeConfigurations."paul@macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.macbook.system};
        extraSpecialArgs = { inherit inputs; hostname = systems.macbook.hostname; };
        modules = [
          ./users/paul/home.nix
          { nixpkgs.config.allowUnfree = true; }
        ];
      };

      homeConfigurations."admin@nuc" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.nuc.system};
        extraSpecialArgs = { inherit inputs; hostname = systems.nuc.hostname; };
        modules = [
          ./users/admin/home.nix
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    };
}