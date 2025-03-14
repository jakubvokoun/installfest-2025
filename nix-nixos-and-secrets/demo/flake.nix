{
  description = "System configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.default
            {
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
              home-manager.useUserPackages = true;
              home-manager.users.vagrant = import ./home.nix;
            }
          ];
        };
      };
    };
}
