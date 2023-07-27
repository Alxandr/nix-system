@default:
  just --list

install-vm-test disk:
	@just format vm-test "[ \"{{disk}}\" ]"

[private]
format host disks:
	sudo nix run github:nix-community/disko -- --mode disko {{justfile_directory()}}/hosts/{{host}}/disko.nix --arg disks '{{disks}}'
