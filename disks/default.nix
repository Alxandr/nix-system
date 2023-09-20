{ ... }:
{
  # imports = [ ./root-btrfs.nix ];
  flake.diskoConfigurations = {
    root-btrfs = import ./root-btrfs.nix;
  };
}
