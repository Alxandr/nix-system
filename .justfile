[private]
@default:
	just --choose

# Update sops secrets with new keys
@update-keys:
	sops updatekeys secrets/*
	sops updatekeys certs/*/key

[private]
@ensure-host-key:
	test -f /etc/ssh/ssh_host_ed25519_key.pub || sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Get host age key
@host-key: ensure-host-key
	cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

@generate-cert NAME:
	openssl req \
		-new -newkey ed25519 -nodes -x509 \
		-keyout ./certs/{{NAME}}/key \
		-out ./certs/{{NAME}}/cert \
		-config ./certs/{{NAME}}/config \
		-days 36525 \
		-extensions v3_req

	sops encrypt -i ./certs/{{NAME}}/key
