{ config, lib, hostName ? "nixos", pkgs, ... }:
let cfg = config.services.laravel;
in
{
  imports = [
    ../web-apps/laravel.nix
  ];
  config = lib.mkMerge [
    {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      virtualisation.virtualbox.guest.enable = true;

      # Mount a VirtualBox shared folder.
      fileSystems."/vagrant" = {
        fsType = "vboxsf";
        device = "vagrant";
        options = [ "rw,uid=1001,gid=60,_netdev" ]; # mount as vagrant:nginx
      };

      # networking.hostName = hostName;
      # networking.extraHosts = ''
      #   127.0.0.1 ${config.networking.hostName}.local
      # '';

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

      environment.systemPackages = with pkgs; [
        direnv
        mcfly
      ];

      programs.bash.shellInit = ''
        eval "$(direnv hook bash)";
        eval "$(mcfly init bash)";
        cd /vagrant;
      '';
    }
    (lib.mkIf (cfg.enable == true) {
      services.laravel.root = lib.mkDefault "/vagrant";
      # services.laravel.domain = lib.mkDefault (hostName + ".local");
      services.laravel.user = lib.mkDefault "vagrant";
    })
  ];
}
