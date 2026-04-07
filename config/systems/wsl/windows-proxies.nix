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

in
{
  environment.systemPackages = [
    (mkProxy { name = "op"; })
  ];
}
