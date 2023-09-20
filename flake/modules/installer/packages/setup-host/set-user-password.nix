{ writeShellApplication

, mkpasswd
, coreutils
, gum
}:

writeShellApplication {
  name = "set-user-password";

  text =
    ''
      file=$1
      user=$2
      dir=$(${coreutils}/bin/dirname "$file")
      ${coreutils}/bin/mkdir -p "$dir"
      PWD=$(${gum}/bin/gum input --password --header="$user password")
      echo "$PWD" | ${mkpasswd}/bin/mkpasswd - >"$file"
      if [ -z "$PWD" ]; then
        ${gum}/bin/gum format "❌ No password provided"
        exit 1
      fi
      ${coreutils}/bin/chmod -v 0400 "$file" >/dev/null
      ${coreutils}/bin/chown root:root "$file" >/dev/null
      ${gum}/bin/gum format "✔️ Password set"
    '';
}
