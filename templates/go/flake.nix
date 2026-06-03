{
  description = "A dev environment";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , nixpkgs-unstable
    , process-compose-flake
    , treefmt-nix
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.process-compose-flake.flakeModule
      ];
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, system, inputs', ... }: {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;

            overlays = [
              (final: prev: { unstable = inputs'.nixpkgs-unstable.legacyPackages; })
            ];
          };

          treefmt = {
            # Used to find the project root
            projectRootFile = "flake.nix";
            settings.global.excludes = [
              ".direnv/**"
              ".jj/**"
              ".env"
              ".envrc"
              ".env.local"
            ];


            # Format nix files
            programs.nixpkgs-fmt.enable = true;
            programs.deadnix.enable = true;

            # Format js, json, and yaml files
            programs.prettier.enable = true;
            settings.formatter.prettier =
              {
                excludes = [
                  "assets/vendor/**"
                  "public/**"
                  "resources/js/modernizr.js"
                  "storage/app/caniuse.json"
                  "templates/**"
                  "*.md"
                ];
              };

            # Appears to be broken?
            programs.golangci-lint.enable = false;
          };

          packages.default = pkgs.buildGoModule rec {
            # pname = "package-name";
            version = "0.1.0";
            src = ./.;
            vendorHash = "sha256-0000000000000000000000000000000000000000000=";

            env.CGO_ENABLED = 1;
            buildInputs = [ pkgs.sqlite ];

            # subPackages = [ ];

            ldflags = [
              "-X git.verticalaxion.com/verticalaxion/sales-tracker-go/internal/config.Version=${version}"
            ];

            # postInstall = ''
            #   mkdir -p $out/lib
            #   cp -r ${src}/templates $out/lib/templates
            #   cp -r ${src}/assets $out/lib/assets
            # '';
          };

          # Run this with nix run .#dev
          process-compose.dev.settings.processes = {
            mail.command = "${pkgs.mailhog}/bin/MailHog";
            web.command = "${pkgs.caddy}/bin/caddy run";
            web.is_elevated = true;
            docs.command = "${pkgs.pkgsite}/bin/pkgsite --http localhost:6060";
          };

          devShells.default = pkgs.mkShell
            {
              buildInputs = with pkgs; [
                go
                # Extra Packages go here.

                # tools
                air
                tailwindcss_4
                goose

                # code quality
                gopls
                gotools
                golangci-lint
                typescript-language-server
                
                # IDE
                unstable.helix
                typescript-language-server
                # vscode-json-languageserver
                vscode-langservers-extracted
              ];
            };
        };
    };
}
