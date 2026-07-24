{
  pkgs,
  lib,
  ...
}:
let
  mkProxy =
    {
      name,
      binary ? "${name}.exe",
    }:
    pkgs.writeShellApplication {
      inherit name;

      text = ''
        exec "${binary}" "$@"
      '';
    };

  opProxy = mkProxy { name = "op"; };

in
{
  environment.systemPackages = [
    opProxy
  ];

  environment.variables.OP_DIRENV_OP = lib.getExe opProxy;
}
