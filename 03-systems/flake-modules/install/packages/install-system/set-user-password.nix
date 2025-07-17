{
  writeShellApplication,
  gum,
  shadow,
}:

writeShellApplication {
  name = "set-user-password";

  text = ''
    root=$1
    user=$2

    if ${gum}/bin/gum confirm "Allow password login for $user?" ; then
      ${shadow}/bin/passwd --root "$root" "$user"
      ${gum}/bin/gum format "✔️ User $user can login with password"
    else
      ${shadow}/bin/passwd --root "$root" --delete "$user"
      ${gum}/bin/gum format "❌ User $user cannot login with password"
      exit 1
    fi
  '';
}
