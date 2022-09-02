{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/22.05";

    sbrow.url = "github:sbrow/nix";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, sbrow }:
    flake-utils.lib.eachSystem flake-utils.lib.allSystems
      (system: {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      }) // {
      nixosModules.default = { config, pkgs, ... }: {
        config = {
          environment.systemPackages = with [ pkgs.git ];
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
