{ writeShellApplication
, lib
, system

, nix
, gum
, disko
, coreutils
, bash
, openssl
, shadow
, pkgs
, nixos-install-tools

, nixosConfiguration
, name
, flake
}:

let
  diskoScript = disko.diskoScript nixosConfiguration pkgs;
  generateKeyPkg = pkgs.callPackage ./generate-key.nix { };
  generateKey = "${generateKeyPkg}/bin/generate-key";
  collectKeyPkg = pkgs.callPackage ./collect-key.nix { };
  collectKey = "${collectKeyPkg}/bin/collect-key";
  setUserPasswordPkg = pkgs.callPackage ./set-user-password.nix { };
  setUserPassword = "${setUserPasswordPkg}/bin/set-user-password";
  scriptLines = builtins.concatStringsSep "\n";

  keys = lib.mapAttrsToList
    (name: cfg: {
      inherit (cfg) path;
      keyScript =
        if cfg.interactive
        then ''${collectKey} "${cfg.path}"''
        else ''${generateKey} "${cfg.path}"'';
      copyScript =
        if cfg.interactive
        then [ ]
        else [
          ''${coreutils}/bin/mkdir -p "/mnt${builtins.dirOf cfg.path}" >/dev/null''
          ''${coreutils}/bin/cp "${cfg.path}" "/mnt${cfg.path}" >/dev/null''
        ];
    })
    nixosConfiguration.disko.keys;

  keyLines =
    let
      keyLines = builtins.map (x: x.keyScript) keys;
    in
    if builtins.length keyLines == 0
    then [ ]
    else [ ''${gum}/bin/gum format "🔑 Setup disk encryption"'' ] ++ keyLines;

  copyLines =
    let
      copyLines = lib.flatten (builtins.map (x: x.copyScript) keys);
    in
    if builtins.length copyLines == 0
    then [ ]
    else [ ''${gum}/bin/gum format "📁 Copy keys to new system"'' ] ++ copyLines;

  normalUsers = lib.filterAttrs (name: cfg: cfg.isNormalUser) nixosConfiguration.users.users;
  userSetupLines = lib.mapAttrsToList
    (n: user:
      let
        name = user.name or n;
        passwordFile = user.hashedPasswordFile or user.passwordFile;
      in
      if passwordFile == null
      then ''${gum}/bin/gum format "warning: no password file configured for user '${name}' - it will not be possible to sign in as this user''
      else ''${setUserPassword} "/mnt${passwordFile}" "${name}"''
    )
    normalUsers;
in
writeShellApplication
{
  name = "install-${name}";

  text =
    ''
      # configure/setup keys
      ${scriptLines keyLines}

      # format disk
      ${gum}/bin/gum spin --spinner line --title "Formatting disk..." --show-output -- ${diskoScript}
      ${gum}/bin/gum format "✔️ Disk formatted"

      # copy keys to new system
      ${scriptLines copyLines}

      # set users
      ${scriptLines userSetupLines}

      # install system
      ${gum}/bin/gum spin --spinner line --title "Refresh flake..." --show-output -- ${nix}/bin/nix --experimental-features "nix-command flakes" flake metadata --refresh -- ${flake.path} >/dev/null
      ${gum}/bin/gum spin --spinner line --title "Installing system..." --show-output -- ${nixos-install-tools}/bin/nixos-install --flake "${flake.path}#${flake.name}" --no-root-password
      ${gum}/bin/gum format "✔️ System installed"
    '';
}
