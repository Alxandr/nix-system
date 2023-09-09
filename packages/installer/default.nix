{ stdenvNoCC, makeWrapper, lib, coreutils, bash, setup-packages }:
let
  hostcases = builtins.mapAttrs (name: setup: "${name})\n    exec \"${setup}/bin/${setup.name}\"\n    ;;") setup-packages;
  hostcases-string = builtins.concatStringsSep "\n  " (lib.attrValues hostcases);
  hostswitch = ''
    case "$1" in
      ${hostcases-string}
      *)
        echo "Unknown host: $1"
        exit 1
        ;;
    esac
    shift
  '';
in
stdenvNoCC.mkDerivation {
  name = "alxandr-nixos-installer";
  src = ./.;
  env = {
    HOST_SWITCH = hostswitch;
  };
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    set -e
    mkdir -p $out/bin $out/bin
    cat >"$out/bin/install" <<EOF
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ \$# -eq 0 ]] || [[ \$# -gt 1 ]]; then
      echo "Must provide exactly one argument: the hostname"
      exit 1
    fi

    # host switch
    $HOST_SWITCH

    EOF
    chmod 755 "$out/bin/install"
  '';
  postFixup = ''
    wrapProgram "$out/bin/install" --set PATH ${lib.makeBinPath [coreutils bash]}
  '';
  meta = with lib; {
    description = "Format disks with nix-config and installs NixOS";
    homepage = "https://github.com/Alxandr/nix-system";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
