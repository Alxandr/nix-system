{ stdenvNoCC, makeWrapper, lib, disko, host, coreutils, bash, flake, pkgs, openssl }:
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
in
stdenvNoCC.mkDerivation {
  name = "setup-${ host. name}";
  src = ./.;
  env = {
    DISKO_SCRIPT = diskoScript;
    GEN_KEYS = keyScripts.genKeys;
    COPY_KEYS = keyScripts.copyKeys;
  };
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    set -e
    mkdir -p $out/bin $out/bin
    cat >"$out/bin/setup-${host.name}" <<EOF
    #!/usr/bin/env bash
    set -euo pipefail

    # gen keys
    $GEN_KEYS

    echo -e "\x1b[1;32m === Formatting disks for host ${host.name} === \x1b[0m"

    # disko script
    $DISKO_SCRIPT

    # copy keys
    $COPY_KEYS
    EOF
    chmod 755 "$out/bin/setup-${host.name}"
  '';
  postFixup = ''
    wrapProgram "$out/bin/setup-${host.name}" --set PATH ${lib.makeBinPath [coreutils bash openssl]}
  '';
  meta = with lib; {
    description = "Format disks with nix-config and installs NixOS for host ${host.name}";
    homepage = "https://github.com/Alxandr/nix-system";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
