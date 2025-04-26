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
    };
  
    outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
      let
        systems = {
          x1 = { hostname = "x1"; system = "x86_64-linux"; };
          macbook = { hostname = "macbook"; system = "aarch64-darwin"; };
        };
      in {
        # NixOS configuration
        nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
          system = systems.x1.system;
          specialArgs = { inherit inputs; hostname = systems.x1.hostname; };
          modules = [
            ./hosts/x1/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.paul = import ./users/paul/home.nix;
            }
          ];
        };
  
        # Darwin configuration
        darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
          system = systems.macbook.system;
          specialArgs = { inherit inputs; hostname = systems.macbook.hostname; };
          modules = [
            ./hosts/macbook/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.paul = import ./users/paul/home.nix;
            }
          ];
        };
  
        # Home Manager standalone configuration (for command: home-manager switch --flake)
        homeConfigurations."paul@x1" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${systems.x1.system};
          extraSpecialArgs = { inherit inputs; hostname = systems.x1.hostname; };
          modules = [
            ./users/paul/home.nix
          ];
        };
      };
  }