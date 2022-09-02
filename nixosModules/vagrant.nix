{ config, ... }: {
  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    virtualisation.virtualbox.guest.enable = true;

    # Mount a VirtualBox shared folder.
    fileSystems."/vagrant" = {
      fsType = "vboxsf";
      device = "vagrant";
      options = [ "rw,uid=1001,gid=60,_netdev" ]; # mount as vagrant:nginx
    };

    networking.extraHosts = ''
      127.0.0.1 ${config.networking.hostName}.local
    '';

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

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = false;
      };
    };
  };
}
