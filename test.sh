TEMPDIR=$(mktemp -d /tmp/sshkeytest.XXXXXX)
trap "rm -rf $TEMPDIR" EXIT

# Export the key in pkcs8 format from 1password
op.exe read "op://Private/Nix-system SOPS age key/private key" > $TEMPDIR/key
chmod 600 $TEMPDIR/key

# Convert the key to openssh format
ssh-keygen -p -m PEM -f $TEMPDIR/key -q -N ""