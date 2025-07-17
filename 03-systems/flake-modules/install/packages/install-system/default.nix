{
  writeShellApplication,
  lib,

  # packages
  nix,
  gum,
  pkgs,
  nixos-install,

  #inputs
  nixosConfiguration,
  name,
  flake,
}:

let
  scriptLines = builtins.concatStringsSep "\n";
  diskoScripts = nixosConfiguration.disko.devices._scripts {
    inherit pkgs;
    checked = false;
  };

  setUserPassword = pkgs.callPackage ./set-user-password.nix { } |> lib.getExe;

  userSetupLines =
    nixosConfiguration.users.users
    |> lib.filterAttrs (
      name: cfg: cfg.isNormalUser && (cfg.hashedPasswordFile or cfg.passwordFile) == null
    )
    |> lib.mapAttrsToList (n: user: ''${setUserPassword} "/mnt" "${user.name or n}"'');

in
writeShellApplication {
  name = "install-${name}";

  text = ''
    # format disk
    ${diskoScripts.format}
    ${lib.getExe gum}/bin/gum format "✔️ Disk formatted"

    # install system
    ${lib.getExe gum} spin --spinner line --title "Refresh flake..." --show-output -- ${nix}/bin/nix --experimental-features "nix-command flakes" flake metadata --refresh -- "${flake.path}" >/dev/null
    ${lib.getExe nixos-install} --flake "${flake.configSpecifier}" --no-root-password
    ${lib.getExe gum} format "✔️ System installed"

    # configure users
    ${scriptLines userSetupLines}
  '';
}
