{ writeShellApplication
, lib
, system

, gum
, coreutils
, bash
, setupPackages
}:

writeShellApplication {
  name = "install";

  text =
    let
      pkgs = builtins.attrValues setupPackages;
      len = builtins.length pkgs;
      isEmpty = len == 0;
      isSingle = len == 1;
      scriptLines = builtins.concatStringsSep "\n";

      prefix = prefix: lines: builtins.map (s: "${prefix}${s}") lines;
      indent = prefix "  ";

      mkHostExec = pkg: [
        ''${gum}/bin/gum format "Installing host '${pkg.setupMeta.name}'"''
        ''exec ${pkg}''
      ];
    in
    if isEmpty
    then
      ''
        ${gum}/bin/gum format "❌ No host supported for this architecture"
        exit 1
      ''
    else if isSingle
    then
      let pkg = builtins.elemAt pkgs 0;
      in scriptLines (mkHostExec pkg)
    else
      let
        names = builtins.map (pkg: ''"${pkg.setupMeta.name}"'') pkgs;
        hostSwitchCases = lib.flatten (builtins.map
          (pkg:
            indent ([ ''${pkg.setupMeta.name})'' ] ++ (indent ((mkHostExec pkg) ++ [ ";;" ])))
          )
          pkgs);
      in
      ''
        if [[ $# -eq 0 ]]; then
        ${gum}/bin/gum format "Select host to install:"
          HOST=$(${gum}/bin/gum choose ${builtins.concatStringsSep " " names})
        else
          HOST="$1"
        fi

        case "$HOST" in
        ${scriptLines hostSwitchCases}
          *)
            ${gum}/bin/gum format "❌ Host '$1' not found on this architecture"
            exit 1
            ;;
        esac
      '';
}
