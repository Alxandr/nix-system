{ writeShellApplication

, gum, shadow }:

writeShellApplication {
  name = "set-user-password";

  text = ''
    root=$1
    user=$2


    if ${gum}/bin/gum confirm "Allow login for $user?" ; then
      ${shadow}/bin/passwd --root "$root" "$user"
      ${gum}/bin/gum format "✔️ User $user can login"
    else
      ${shadow}/bin/passwd --root "$root" --delete "$user"
      ${gum}/bin/gum format "❌ User $user cannot login"
      exit 1
    fi
  '';
}
