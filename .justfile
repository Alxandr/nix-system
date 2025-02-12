[private]
@default:
	just --list

# Update sops secrets with new keys
@update-keys:
	sops updatekeys secrets/*
