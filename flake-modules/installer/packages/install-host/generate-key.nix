{ writeShellApplication

, gum
, coreutils
, openssl
}:
let
  generate = writeShellApplication {
    name = "generate-key";

    text =
      ''
        file=$1
        dir=$(${coreutils}/bin/dirname "$file")
        ${coreutils}/bin/mkdir -p "$dir"
        ${openssl}/bin/openssl genrsa -out "$file" 4096
        ${coreutils}/bin/chmod -v 0400 "$file" >/dev/null
        ${coreutils}/bin/chown root:root "$file" >/dev/null
      '';
  };
in
writeShellApplication {
  name = "generate-key";

  text =
    ''
      ${gum}/bin/gum spin --spinner line --title "Generating key..." --show-output -- ${generate}/bin/generate-key "$1"
      ${gum}/bin/gum format "✔️ Key generated"
    '';
}
