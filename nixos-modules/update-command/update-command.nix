{ writeShellApplication
, lib
, system
, bash
, nixos-rebuild
, flakeMeta
}:

writeShellApplication {
  name = "update-system";

  text =
    ''
      cmd=''${1:-switch}
      ${nixos-rebuild}/bin/nixos-rebuild "$cmd" --flake "${flakeMeta.configPath}"
    '';
}
