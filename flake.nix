{
  description = "NixOS 25.05 + Home Manager + personal dev env + Neovim from GitHub";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in {
    nixosConfigurations.nixos = lib.nixosSystem {
      inherit system;

      # Make flake inputs available to modules (e.g., home/jkutz.nix)
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        ./home/jkutz.nix
      ];
    };
  };
}

