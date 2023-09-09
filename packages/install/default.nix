{ writeShellApplication
, lib
, system

, coreutils
, bash
, setup-packages
}:

let
  hostcases = builtins.mapAttrs
    (name: setup:
      if setup.host.supportsSystem system
      then "${name})\n    exec \"${setup}/bin/${setup.name}\"\n    ;;"
      else "${name})\n    echo \"${setup.name} is not supported on ${system}\"\n    exit 1;    ;;")
    setup-packages;
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
writeShellApplication {
  name = "install";

  text = ''
    if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
      echo "Must provide exactly one argument: the hostname"
      exit 1
    fi

    # host switch
    ${hostswitch}
  '';
}
