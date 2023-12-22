{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/23.11";

    sbrow.url = "github:sbrow/nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, sbrow }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              # Your packages here
            ];
          };
      };
    };
}
