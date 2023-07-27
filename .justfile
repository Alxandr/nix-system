memory        := `grep MemTotal /proc/meminfo | awk '{print $2}'` + "k"

@default:
  just --list

install host disk:
	@just _format {{host}} "[ \"{{disk}}\" ]"
	nixos-generate-config --no-filesystems --root /mnt
	nixos-install

[private]
_format host disks:
	sudo nix run github:nix-community/disko -- --mode disko {{justfile_directory()}}/hosts/{{host}}/disko.nix --arg disks '{{disks}}' --arg memory '"{{memory}}"'
