{
  pkgs,
  lib,
  # Whether to enable module type checking.
  check ? true,
}:

with lib;

let

  modules = [
    ./user.nix
    ./group.nix
    ./home.nix
    ./trusted.nix
    ./1password.nix
    (pkgs.path + "/nixos/modules/misc/assertions.nix")
    (pkgs.path + "/nixos/modules/misc/meta.nix")
  ];

  pkgsModule =
    { config, ... }:
    {
      config = {
        _module.args.baseModules = modules;
        _module.args.pkgsPath = lib.mkDefault (
          if versionAtLeast config.home.stateVersion "20.09" then pkgs.path else <nixpkgs>
        );
        _module.args.pkgs = lib.mkDefault pkgs;
        _module.check = check;
      };
    };

in
modules ++ [ pkgsModule ]
