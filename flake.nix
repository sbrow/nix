{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {
    nixosModules.vagrant = { ... }: { imports = [ ./nixosModules/vagrant.nix ]; };
  };
}
