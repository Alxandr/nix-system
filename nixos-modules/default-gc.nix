{ ... }:
{ lib, ... }: {
  config = {
    # do garbage collection weekly to keep disk usage low
    nix.gc = lib.mkDefault {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3w";
    };

    # Manual optimise storage: nix-store --optimise
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    nix.settings.auto-optimise-store = true;
  };
}
