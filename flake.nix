# flake.nix
{
  description = "Dhilipan's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, chaotic, disko }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        dhilipan = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            pkgs-unstable = pkgs;
          };
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            ./modules/boot.nix
            ./modules/gaming.nix
            ./modules/graphics.nix
            ./modules/audio.nix
            ./modules/system.nix
            ./modules/udev.nix
            ./modules/tweaks.nix
            ./modules/disko.nix
            chaotic.nixosModules.default
          ];
        };
      };
    };
}