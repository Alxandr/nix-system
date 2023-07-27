memory        := `grep MemTotal /proc/meminfo | awk '{print $2}'` + "k"

@default:
	just --list

install host disk:
	@just _format {{host}} "[ \"{{disk}}\" ]"
	nixos-install --flake github:Alxandr/nix-system#{{host}} --no-root-password

build-all:
	for host in $(nix eval .#hosts --accept-flake-config --json | jq -r '.[]'); do \
		echo "Building for $host"; \
		nix build -L --accept-flake-config ".#nixosConfigurations.${host}.config.system.build.toplevel"; \
	done

[private]
_format host disks:
	nix run github:nix-community/disko -- --mode disko {{justfile_directory()}}/hosts/{{host}}/disko.nix --arg disks '{{disks}}' --arg memory '"{{memory}}"'
