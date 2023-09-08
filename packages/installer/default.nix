{ stdenvNoCC, makeWrapper, lib, disko, hostnames, coreutils, bash }:
let
  flake = "github:Alxandr/nix-system";
  hostcases = builtins.map (host: "${host})\n    host=${host}\n    ;;") hostnames;
  hostcases-string = builtins.concatStringsSep "\n  " hostcases;
  hostswitch = ''
    case "\$1" in
      ${hostcases-string}
      *)
        echo "Unknown host: \$1"
        exit 1
        ;;
    esac
    shift
  '';
in
stdenvNoCC.mkDerivation {
  name = "alxandr-nixos-installer";
  src = ./.;
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    mkdir -p $out/bin $out/bin
    {
      cat <<EOF
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ \$# -eq 0 ]] || [[ \$# -gt 1 ]]; then
      echo "Must provide exactly one argument: the hostname"
      exit 1
    fi

    host=""
    ${hostswitch}

    echo -e "\x1b[1;32m === Formatting disks for host \$host === \x1b[0m"
    disko --mode disko --flake "${flake}.#\$host"
    EOF
    } >"$out/bin/install"
    chmod 755 "$out/bin/install"
  '';
  postFixup = ''
    wrapProgram "$out/bin/install" --set PATH ${lib.makeBinPath [disko coreutils bash]}
  '';
  meta = with lib; {
    description = "Format disks with nix-config and installs NixOS";
    homepage = "https://github.com/Alxandr/nix-system";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
