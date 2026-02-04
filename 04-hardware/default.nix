{ inputs, ... }:
let
  inherit (inputs) nixos-hardware;
in
{
  config.flake = {
    nixosModules =
      # Re-export all nixos-hardware modules
      nixos-hardware.nixosModules
      // {
        # Custom hardware modules (amendments)
        minisforum-ms-s1-max = ./nixos-modules/minisforum-ms-s1-max.nix;
      };
  };
}
