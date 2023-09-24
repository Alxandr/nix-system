{ lib, ... }:
with lib; {
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;

  services.xserver.videoDrivers = [ "vmware" "virtualbox" "modesetting" ];
  systemd.user.services =
    let
      vbox-client = desc: flags: {
        description = "VirtualBox Guest: ${desc}";

        wantedBy = [ "graphical-session.target" ];
        requires = [ "dev-vboxguest.device" ];
        after = [ "dev-vboxguest.device" ];

        unitConfig.ConditionVirtualization = "oracle";

        serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv ${flags}";
      };
    in
    {
      virtualbox-resize = vbox-client "Resize" "--vmsvga";
      virtualbox-clipboard = vbox-client "Clipboard" "--clipboard";
    };
}
