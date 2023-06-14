{
  description = "Utilities for running Laravel, particularly with Vagrant";

  outputs = { nixpkgs, self }: {
    nixosModules = {
      laravel = import ./nixos/modules/web-apps/laravel.nix;
      vagrant = { ... }: { imports = [ ./nixos/modules/virtualisation/vagrant.nix ]; };
    };

    templates = {
      default = {
        path = ./templates/default;
        description = "A simple boilerplate for running Laravel on NixOS in a Vagrant machine.";
      };
      nodejs = {
        path = ./templates/nodejs;
        description = "A simple boilerplate for running Node.js apps in a nix shell.";
      };
      php = {
        path = ./templates/php;
        description = "A simple boilerplate for running PHP apps in a nix shell.";
      };
    };

    checks."x86_64-linux".vagrant = let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in pkgs.nixosTest {
      name = "vagrant-box-test";
      nodes.machine = { config, pkgs, ... }: {
        imports = [ self.nixosModules.vagrant ];
        config = {
          assertions = [
            {
              assertion = config.services.laravel.enable == false;
              message = "Laravel should be disabled";
            }
            {
              assertion = config.services.laravel.bashAliases.enable == config.services.laravel.enable;
              message = "Bash aliases should be enabled";
            }
          ];
        };
        };
      testScript = ''
        # run hello on machine and check for output
        # test is a simple python script
        machine.succeed('cd /vagrant && php artisan')
      '';
    };
  };
}
