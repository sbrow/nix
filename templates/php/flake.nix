{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    # phps.url = "github:fossar/nix-phps";
    # phps.inputs.nixpkgs.follows = "nixpkgs";

    sbrow.url = "github:sbrow/nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, /* phps, */ sbrow }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, system, ... }:
        /* let phpPkgs = phps.legacyPackages.${system}; in */ {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              caddy
              foreman
              php
              phpPackages.composer
            ];
          };
      };
    };
}
