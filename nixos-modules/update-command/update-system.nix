{ writeShellApplication, lib, system, bash, nixos-rebuild, nix, flakeMeta }:

writeShellApplication {
  name = "update-system";

  text = ''
    cmd=''${1:-boot}
    ${nixos-rebuild}/bin/nixos-rebuild "$cmd" --flake "${flakeMeta.configPath}" --refresh
  '';
}
