{ writeShellApplication
, lib
, system

, coreutils
, bash
, setup-packages
}:

writeShellApplication {
  name = "install";

  text =
    let
      isSingleHost = (builtins.length (builtins.attrNames setup-packages)) == 1;

      prefix = prefix: lines: builtins.map (s: "${prefix}${s}") lines;
      indent = prefix "  ";

      toString = lines: builtins.concatStringsSep "\n" lines;

      mkHostExec = setup:
        if setup.host.supportsSystem system
        then [ "exec \"${setup}/bin/${setup.name}\"" ]
        else [ "${coreutils}/bin/echo \"${setup.name} is not supported on ${system}\"" "exit 1" ];

      mkHostSwitchCase = name: setup:
        indent ([ "${name})" ] ++ indent (mkHostExec setup ++ [ ";;" ]));

      hostSwitchCases = lib.flatten (lib.attrValues (builtins.mapAttrs mkHostSwitchCase setup-packages));
      hostSwitch = [ ''case "$1" in'' ] ++ hostSwitchCases ++ [
        "  *)"
        "    ${coreutils}/bin/echo \"Unknown host: $1\""
        "    exit 1"
        "    ;;"
      ] ++ [ "esac" ];

      text =
        if isSingleHost
        then
          ''
            if [[ $# -ne 0 ]]; then
              ${coreutils}/bin/echo "No arguments expected"
              exit 1
            fi

            ${toString (mkHostExec (builtins.elemAt (builtins.attrValues setup-packages) 0))}
          ''
        else
          ''
            if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
              ${coreutils}/bin/echo "Must provide exactly one argument: the hostname"
              exit 1
            fi

            ${toString hostSwitch}
          '';
    in
    text
  ;
}
