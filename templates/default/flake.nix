{
  # description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";


    flake-parts.url = "github:hercules-ci/flake-parts";
    # process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    # sbrow.url = "github:sbrow/nix";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, nixpkgs-unstable/*, process-compose-flake, sbrow */ }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        # inputs.process-compose-flake.flakeModule
      ];

      perSystem = { inputs', pkgs, system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;

          overlays = [
            (final: prev: { unstable = inputs'.nixpkgs-unstable.legacyPackages; })
          ];
        };

        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              # Your packages here
            ];
          };

        #  process-compose.default.settings = { };
      };
    };
}
