{
  writeShellApplication,
  lib,
  pkgs,

  # packages
  gum,

  # inputs
  installers,
  isSingle,
}:

let
  scriptLines = builtins.concatStringsSep "\n";
  count =
    installers
    |> lib.attrsets.foldlAttrs (
      acc: name: cfg:
      acc + 1
    ) 0;

  # prefix = prefix: lines: builtins.map (s: "${prefix}${s}") lines;
  # indent = prefix "  ";
  prefixLines =
    prefix: text:
    text
    |> lib.strings.splitString "\n"
    |> lib.lists.map (s: "${prefix}${s}")
    |> builtins.concatStringsSep "\n";

  indent = prefixLines "  ";

  mkExec = name: pkg: ''
    ${lib.getExe gum} format "Installing host '${name}'"
    exec ${lib.getExe pkg}'';

in
writeShellApplication {
  name = "install";

  text =
    if count == 0 then
      ''
        echo "Current architecture (${pkgs.stdenv.hostPlatform.system}) is not supported by any nixosConfigurations in this flake."
      ''
    else if isSingle then
      let
        installer = installers |> lib.attrsets.mapAttrsToList mkExec |> lib.lists.head;
      in
      installer
    else
      let
        names = installers |> lib.attrsets.mapAttrsToList (name: pkg: name);
        switchCases =
          installers
          |> lib.attrsets.mapAttrsToList (
            name: pkg:
            ''
              ${name})
              ${mkExec name pkg |> indent}
                ;;
            ''
            |> indent
          )
          |> scriptLines;
      in
      ''
        if [[ $# -eq 0 ]]; then
          # ${lib.getExe gum} format "Select host to install:"
          HOST=$(printf "${builtins.concatStringsSep "\\n" names}" | ${lib.getExe gum} filter --placeholder "Select host")
        else
          HOST=$1
        fi

        case "$HOST" in
        ${switchCases}
          *)
            ${lib.getExe gum} format "❌ Host '$HOST' not found on this architecture"
            exit 1
            ;;
        esac
      '';
}
