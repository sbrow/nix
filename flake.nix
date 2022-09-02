{
  description = "A very basic flake";

  outputs = { self }: {
    nixosModules.vagrant = { ... }: { imports = [ ./nixosModules/vagrant.nix ]; };
  };
}
