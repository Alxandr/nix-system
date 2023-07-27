memory        := `grep MemTotal /proc/meminfo | awk '{print $2}'` + "k"

@default:
  just --list

install host disk:
	@just _format {{host}} "[ \"{{disk}}\" ]"
	nixos-install --flake github:Alxandr/nix-system#{{host}}

[private]
_format host disks:
	nix run github:nix-community/disko -- --mode disko {{justfile_directory()}}/hosts/{{host}}/disko.nix --arg disks '{{disks}}' --arg memory '"{{memory}}"'
