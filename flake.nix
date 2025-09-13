{
  description = "Home Manager flake for jkutz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # HM-only: define a home configuration (no nixosConfigurations here)
    homeConfigurations."jkutz@nixos" =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jkutz.nix ];
      };
  };
}


