{
  writeShellApplication,
  pkgs,
  flakeMeta,
}:

writeShellApplication {
  name = "update-system";

  text = ''
    cmd=''${1:-boot}
    # ${pkgs.nixos-rebuild}/bin/nixos-rebuild "$cmd" --flake "${flakeMeta.configPath}" --refresh
    ${pkgs.nh}/bin/nh os "$cmd" "${flakeMeta.path}" --hostname "${flakeMeta.configName}" --update --ask
  '';
}
