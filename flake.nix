{
  description = "A very basic flake";

  outputs = { nixpkgs, self }: {
    nixosModules = {
      laravel = import ./nixos/modules/web-apps/laravel.nix;
      vagrant = { ... }: { imports = [ ./nixos/modules/virtualisation/vagrant.nix ]; };
    };
  };
}
