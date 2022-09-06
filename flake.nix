{
  description = "A very basic flake";

  outputs = { self }: {
    nixosModules.vagrant = { ... }: { imports = [ ./nixos/modules/virtualisation/vagrant.nix ]; };
  };
}
