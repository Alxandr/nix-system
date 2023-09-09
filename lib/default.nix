{ lib
, disko
, supportedSystems
, neovim-flake
}:

let
  neovim = import ./neovim.nix { inherit neovim-flake; };
  host = import ./host.nix { inherit lib disko supportedSystems neovim; };
in
{
  inherit (host) mkHost mkHosts;
}
