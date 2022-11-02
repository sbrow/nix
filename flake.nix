{
  description = "Utilities for running Laravel, particularly with Vagrant";

  outputs = { nixpkgs, self }: {
    nixosModules = {
      laravel = import ./nixos/modules/web-apps/laravel.nix;
      vagrant = { ... }: { imports = [ ./nixos/modules/virtualisation/vagrant.nix ]; };
    };

    checks."x86_64-linux".vagrant = let pkgs = nixpkgs.legacyPackages."x86_64-linux"; in
      pkgs.nixosTest {
        name = "vagrant-box-test";
        nodes.machine = { pkgs, ... }: { imports = with self.nixosModules; [ vagrant ]; };
        testScript = ''
          # run hello on machine and check for output
          machine.succeed('hello | grep "Hello, world!"')
          machine.succeed('goodbye | grep "Hello, world!"')
          # test is a simple python script
        '';
      };
  };
}
