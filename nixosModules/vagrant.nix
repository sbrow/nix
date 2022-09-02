{ config, ... }: {
  config = {
    virtualisation.virtualbox.guest.enable = true;

    # Mount a VirtualBox shared folder.
    fileSystems."/vagrant" = {
      fsType = "vboxsf";
      device = "vagrant";
      options = [ "rw,uid=1001,gid=60,_netdev" ]; # mount as vagrant:nginx
    };

    security.sudo.wheelNeedsPassword = false;

    users.users.root.password = "vagrant";
    users.users."vagrant" = {
      isNormalUser = true;
      password = "vagrant";
      extraGroups = [
        "nginx"
        "wheel"
        # Allow mounting of shared folders.
        "vboxsf"
      ];
    };

    services.openssh.enable = true;
  };
}
