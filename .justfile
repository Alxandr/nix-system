[private]
@default:
	just --choose

# Update sops secrets with new keys
@update-keys:
	sops updatekeys secrets/*

[private]
@ensure-host-key:
	test -f /etc/ssh/ssh_host_ed25519_key.pub || sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Get host age key
@host-key: ensure-host-key
	cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
