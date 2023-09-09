{ writeShellApplication
, lib
, system

, disko
, coreutils
, bash
, openssl
, pkgs
, nixos-install-tools
, su

, flake
, host
}:

let
  diskoScript = disko.diskoScript host.diskoConfiguration pkgs;
  keyScripts =
    if host.interactive
    then {
      genKeys = "";
      copyKeys = "";
    }
    else
      let
        cmdAttrs = lib.mapAttrs
          (name: path: {
            mkdir = "mkdir -p ${builtins.dirOf path} # ${name}";
            keygen = ''
              # ${name}
              openssl genrsa -out "${path}" 4096
              chmod -v 0400 "${path}"
              chown root:root "${path}"
            '';
            mkdist = "mkdir -p ${builtins.dirOf "/mnt${path}"} # ${name}";
            copy = ''cp "${path}" "/mnt${path}" # ${name}'';
          })
          host.keyFiles;

        cmds = lib.attrValues cmdAttrs;

        mkdirs = builtins.map (cmd: cmd.mkdir) cmds;
        mkdir = builtins.concatStringsSep "\n" mkdirs;

        keygens = builtins.map (cmd: cmd.keygen) cmds;
        keygen = builtins.concatStringsSep "\n" keygens;

        mkdists = builtins.map (cmd: cmd.mkdist) cmds;
        mkdist = builtins.concatStringsSep "\n" mkdists;

        copys = builtins.map (cmd: cmd.copy) cmds;
        copy = builtins.concatStringsSep "\n" copys;

        genKeys = ''
          echo -e "\x1b[1;32m === Generating key-files for host ${host.name} === \x1b[0m"

          # mkdirs
          ${mkdir}

          # keygen
          ${keygen}
        '';

        copyKeys = ''
          echo -e "\x1b[1;32m === Copy key-files for host ${host.name} === \x1b[0m"

          #mkdir
          ${mkdist}

          # copy
          ${copy}
        '';
      in
      {
        inherit genKeys copyKeys;
      };

  configureUserScripts = builtins.attrValues (
    lib.mapAttrs
      (name: user:
        ''
          echo "${name} password:"
          ${su}/bin/passwd --root /mnt "${name}"
        ''
      )
      host.users
  );

  configureUsers = builtins.concatStringsSep "\n" configureUserScripts;
in
writeShellApplication {
  name = "setup-${ host.name }";

  text =
    if !(host.supportsSystem system)
    then "echo -e \"\x1b[1;31mSystem ${system} not supported for host ${host.name}\x1b[0m\""
    else ''
      # gen keys
      ${keyScripts.genKeys}

      echo -e "\x1b[1;32m === Formatting disks for host ${host.name} === \x1b[0m"

      # disko script
      ${diskoScript}

      # copy keys
      ${keyScripts.copyKeys}

      echo -e "\x1b[1;32m === Install system === \x1b[0m"
      ${nixos-install-tools}/bin/nixos-install --flake "${flake}#${host.name}.${system}" --no-root-password
      # --extra-experimental-features "nix-command flakes"?

      echo -e "\x1b[1;32m === Configuring users === \x1b[0m"
      ${configureUsers}
    '';
}
