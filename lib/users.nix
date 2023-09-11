{ lib, homeManagerConfiguration }:
users:
let
  mkIf = cond: val: if cond then val else { };
  mkUser = name: dir:
    let
      withFile = file: f:
        let path = "${dir}/${file}";
        in mkIf (builtins.pathExists path) (f (import path));

      groups =
        let
          path = "${dir}/groups.nix";
          exists = builtins.pathExists path;
        in
        [ name "users" ] ++ (if exists then import path else [ ]);

      common = {
        isNormalUser = true;
        extraGroups = groups;
      };



      authorized-keys = withFile "authorized-keys.nix" (keys: { openssh.authorizedKeys.keys = keys; });

      config = common // authorized-keys;

      home-manager = pkgs: {
        programs.bash.enable = true;
        programs.zsh.enable = true;

        # inherit pkgs;
        # modules = [{
        # home.username = name;
        # home.homeDirectory = "/home/${name}";
        home.stateVersion = "23.05";
        # }];
      };
    in
    {
      inherit config home-manager;
    };
in
builtins.mapAttrs mkUser users
