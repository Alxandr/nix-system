{ writeShellApplication

, coreutils
, gum
}:

writeShellApplication {
  name = "collect-key";

  text =
    ''
      file=$1
      dir=$(${coreutils}/bin/dirname "$file")
      ${coreutils}/bin/mkdir -p "$dir"
      PWD=$(${gum}/bin/gum input --password --header="Disk encryption password")
      echo "$PWD" >"$file"
      if [ -z "$PWD" ]; then
        ${gum}/bin/gum format "❌ No password provided"
        exit 1
      fi
      ${coreutils}/bin/chmod -v 0400 "$file" >/dev/null
      ${coreutils}/bin/chown root:root "$file" >/dev/null
      ${gum}/bin/gum format "✔️ Password set"
    '';
}
