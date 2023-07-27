memory        := `grep MemTotal /proc/meminfo | awk '{print $2}'` + "k"

@default:
  just --list

install host disk:
	@just _format {{host}} "[ \"{{disk}}\" ]"

[private]
_format host disks:
	sudo nix run github:nix-community/disko -- --mode disko {{justfile_directory()}}/hosts/{{host}}/disko.nix --arg disks '{{disks}}' --arg memory '"{{memory}}"'
