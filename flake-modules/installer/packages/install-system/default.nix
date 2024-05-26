{ writeShellApplication, lib, system

, nix, gum, disko, pkgs, nixos-install-tools

, nixosConfiguration, name, flake }:

let
  scriptLines = builtins.concatStringsSep "\n";
  diskoScript = disko.diskoScript nixosConfiguration pkgs;

  setUserPasswordPkg = pkgs.callPackage ./set-user-password.nix { };
  setUserPassword = "${setUserPasswordPkg}/bin/set-user-password";

  normalUsers = lib.filterAttrs (name: cfg:
    cfg.isNormalUser && (cfg.hashedPasswordFile or cfg.passwordFile) == null)
    nixosConfiguration.users.users;
  userSetupLines = lib.mapAttrsToList (n: user:
    let
      name = user.name or n;
      passwordFile = user.hashedPasswordFile or user.passwordFile;
    in ''${setUserPassword} "/mnt" "${name}"'') normalUsers;

in (writeShellApplication {
  name = "install-${name}-${system}";

  text = ''
    # configure/setup keys
    ${""} # scriptLines keyLines}

    # format disk
    ${gum}/bin/gum spin --spinner line --title "Formatting disk..." --show-output -- ${diskoScript}
    ${gum}/bin/gum format "✔️ Disk formatted"

    # copy keys to new system
    ${""} # scriptLines copyLines}

    # install system
    ${gum}/bin/gum spin --spinner line --title "Refresh flake..." --show-output -- ${nix}/bin/nix --experimental-features "nix-command flakes" flake metadata --refresh -- ${flake.path} >/dev/null
    ${nixos-install-tools}/bin/nixos-install --flake "${flake.path}#${flake.name}" --no-root-password
    # ${gum}/bin/gum spin --spinner line --title "Installing system..." --show-output -- ${nixos-install-tools}/bin/nixos-install --flake "${flake.path}#${flake.name}" --no-root-password
    ${gum}/bin/gum format "✔️ System installed"

    # configure users
    ${scriptLines userSetupLines}
  '';
}) // {
  agnostic-name = "install-${name}";
}
