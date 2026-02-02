{
  workloads-lib,
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkDefaultsOption;
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.defaults.gc;
in
{
  options.defaults.gc = mkDefaultsOption {
    name = "gc";
  };

  config = mkIf cfg.enable ({
    # do garbage collection weekly to keep disk usage low
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 3w";
    };

    # Manual optimise storage: nix-store --optimise
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    nix.settings.auto-optimise-store = lib.mkDefault true;
  });
}
