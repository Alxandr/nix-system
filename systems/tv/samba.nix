{ pkgs, ... }: {
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = tv
      netbios name = tv
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      create mask = 0664
      force create mode = 0664
      directory mask = 0775
      force directory mode = 0775
    '';
    shares = {
      alxandr = {
        path = "/home/alxandr";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  # services.samba-wsdd = {
  #   enable = true;
  #   openFirewall = true;
  # };
}
