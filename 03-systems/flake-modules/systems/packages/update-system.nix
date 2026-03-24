{
  writeShellApplication,
  pkgs,
  flakeMeta,
}:

writeShellApplication {
  name = "update-system";

  text = ''
    cmd=''${1:-boot}
    ${pkgs.nh}/bin/nh os "$cmd" "${flakeMeta.path}" --hostname "${flakeMeta.configKey}" --ask --refresh --accept-flake-config
  '';
}
