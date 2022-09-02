{
  description = "A very basic flake";

  inputs = {
    sbrow.url = "github:sbrow/nix";
  };

  outputs = { self, nixpkgs, sbrow }: {
    nixosModules.default = { config, ... }: {
      config = {
        /* Your config here */
      };
    };

    # A Vagrant box for testing
    nixosConfigurations.vagrant = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/virtualbox-image.nix")
        sbrow.nixosModules.vagrant
        self.nixosModules.default
      ];
    };
  };
}
