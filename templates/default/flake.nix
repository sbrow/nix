{
  # description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";


    flake-parts.url = "github:hercules-ci/flake-parts";
    # process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # sbrow.url = "github:sbrow/nix";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, nixpkgs-unstable/*, process-compose-flake, sbrow */, treefmt-nix }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # debug = true;

      systems = [ "x86_64-linux" ];

      imports = [
        # inputs.process-compose-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { inputs', pkgs, system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;

          overlays = [
            (final: prev: { unstable = inputs'.nixpkgs-unstable.legacyPackages; })
          ];
        };

        #formatter = pkgs.nixpkgs-fmt;
        treefmt = {
          # Used to find the project root
          projectRootFile = "flake.nix";

          # Format nix files
          programs.nixpkgs-fmt.enable = true;

          # Format php files
          settings.formatter."pint" =
            {
              command = "./vendor/bin/pint";
              includes = [ "*[!.blade].php" ];
              excludes = [ "_ide_helper*.php" ];
            };

          # Format blade files
          settings.formatter."blade-formatter" = {
            command = "./bin/blade-formatter";
            options = [ "--write" ];
            includes = [ "*.blade.php" ];
          };

          # Format js, json, and yaml files
          programs.prettier.enable = true;
          settings.formatter.prettier =
            {
              excludes = [
                "public/**"
                "resources/js/modernizr.js"
                "storage/app/caniuse.json"
                "*.md"
              ];
            };

          # Format elm components
          programs.elm-format.enable = true;

          # Override the default package
          #programs.terraform.package = nixpkgs.terraform_1;
        };

        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              # config.treefmt.build.wrapper
              # Your packages here
            ];
          };

        #  process-compose.default.settings = { };
      };
    };
}
