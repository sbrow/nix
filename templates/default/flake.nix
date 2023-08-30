{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/23.05";

    sbrow.url = "github:sbrow/nix";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, sbrow }:
    flake-utils.lib.eachSystem flake-utils.lib.allSystems
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          formatter = pkgs.nixpkgs-fmt;

          devShells.default = pkgs.mkShell
            {
              buildInputs = with pkgs; [
                # Your packages here
              ];
            };
        });
}
