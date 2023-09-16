{ writeShellApplication
, lib
, system

, gum
, disko
, coreutils
, bash
, openssl
, shadow
, pkgs
, nixos-install-tools

  # , flake
  # , host
, config
, name
}:

let
  diskoScript = disko.diskoScript config pkgs;
  generateKeyPkg = pkgs.callPackage ./generate-key.nix { };
  generateKey = "${generateKeyPkg}/bin/generate-key";
  collectKeyPkg = pkgs.callPackage ./collect-key.nix { };
  collectKey = "${collectKeyPkg}/bin/collect-key";
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
          ''${coreutils}/bin/mkdir -p "/mnt${builtins.dirOf cfg.path}"''
          ''${coreutils}/bin/cp "${cfg.path}" "/mnt${cfg.path}"''
        ];
    })
    config.disko.keys;

  keyLines =
    let
      keyLines = builtins.map (x: x.keyScript) keys;
    in
    if builtins.length keyLines == 0
    then [ ]
    else [ ''${gum}/bin/gum format "🔑 Setup disk encryption"'' ] ++ keyLines;
  # if builtins.length keys == 0
  # then [ ]
  # else [ ''${gum}/bin/gum format "🔑 Setup disk encryption"'' ] ++ (map (x: x.keyScript) keys);

  copyLines =
    let
      copyLines = lib.flatten (builtins.map (x: x.copyScript) keys);
    in
    if builtins.length copyLines == 0
    then [ ]
    else [ ''${gum}/bin/gum format "📁 Copy keys to new system"'' ] ++ copyLines;
  # if builtins.length keys == 0
  # then [ ]
  # else [ ''${gum}/bin/gum format "🔑 Copy keys to new system"'' ] ++ (map (x: x.copyScript) keys);
  # keyScripts =
  #   if host.interactive
  #   then {
  #     genKeys = "";
  #     copyKeys = "";
  #   }
  #   else
  #     let
  #       cmdAttrs = lib.mapAttrs
  #         (name: path: {
  #           mkdir = "${coreutils}/bin/mkdir -p ${builtins.dirOf path} # ${name}";
  #           keygen = ''
  #             # ${name}
  #             ${openssl}/bin/openssl genrsa -out "${path}" 4096
  #             ${coreutils}/bin/chmod -v 0400 "${path}"
  #             ${coreutils}/bin/chown root:root "${path}"
  #           '';
  #           mkdist = "${coreutils}/bin/mkdir -p ${builtins.dirOf "/mnt${path}"} # ${name}";
  #           copy = ''${coreutils}/bin/cp "${path}" "/mnt${path}" # ${name}'';
  #         })
  #         host.keyFiles;

  #       cmds = lib.attrValues cmdAttrs;

  #       mkdirs = builtins.map (cmd: cmd.mkdir) cmds;
  #       mkdir = builtins.concatStringsSep "\n" mkdirs;

  #       keygens = builtins.map (cmd: cmd.keygen) cmds;
  #       keygen = builtins.concatStringsSep "\n" keygens;

  #       mkdists = builtins.map (cmd: cmd.mkdist) cmds;
  #       mkdist = builtins.concatStringsSep "\n" mkdists;

  #       copys = builtins.map (cmd: cmd.copy) cmds;
  #       copy = builtins.concatStringsSep "\n" copys;

  #       genKeys = ''
  #         ${coreutils}/bin/echo -e "\x1b[1;32m === Generating key-files for host ${host.name} === \x1b[0m"

  #         # mkdirs
  #         ${mkdir}

  #         # keygen
  #         ${keygen}
  #       '';

  #       copyKeys = ''
  #         ${coreutils}/bin/echo -e "\x1b[1;32m === Copy key-files for host ${host.name} === \x1b[0m"

  #         #mkdir
  #         ${mkdist}

  #         # copy
  #         ${copy}
  #       '';
  #     in
  #     {
  #       inherit genKeys copyKeys;
  #     };

  # configureUserScripts = builtins.attrValues (
  #   lib.mapAttrs
  #     (name: user:
  #       ''
  #         ${coreutils}/bin/echo "${name} password:"
  #         ${shadow}/bin/passwd --root /mnt "${name}"
  #       ''
  #     )
  #     host.users
  # );

  # configureUsers = builtins.concatStringsSep "\n" configureUserScripts;
in
writeShellApplication
{
  name = "setup-${name}";

  text =
    ''
      # configure/setup keys
      ${scriptLines keyLines}

      # format disk
      ${gum}/bin/gum format "💾 Format disks"
      ${diskoScript}

      # copy keys to new system
      ${scriptLines copyLines}
    '';
  # if !(host.supportsSystem system)
  # then "echo -e \"\x1b[1;31mSystem ${system} not supported for host ${host.name}\x1b[0m\""
  # else ''
  #   # gen keys
  #   ${keyScripts.genKeys}

  #   ${coreutils}/bin/echo -e "\x1b[1;32m === Formatting disks for host ${host.name} === \x1b[0m"

  #   # disko script
  #   ${diskoScript}

  #   # copy keys
  #   ${keyScripts.copyKeys}

  #   ${coreutils}/bin/echo -e "\x1b[1;32m === Install system === \x1b[0m"
  #   ${nixos-install-tools}/bin/nixos-install --flake "${flake}#${host.name}-${system}" --no-root-password
  #   # --extra-experimental-features "nix-command flakes"?

  #   ${coreutils}/bin/echo -e "\x1b[1;32m === Configuring users === \x1b[0m"
  #   ${configureUsers}
  # '';
}
