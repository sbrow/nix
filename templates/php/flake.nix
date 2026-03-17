{
  description = "A PHP dev environment";

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
        { pkgs, system, inputs', ... }:
        let
          php = pkgs.php.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all; [
              xdebug
            ]));
            extraConfig = ''
              ; Disable short tags
              short_open_tag = off

              ; xdebug 3
              xdebug.mode=debug
              xdebug.client_port=9000

              ; xdebug 2
              ; xdebug.remote_enable=1
            '';
          };
        in
        {
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

            # TODO: Format php files

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
          };

          process-compose.default.settings.processes = {
            web.command = "sudo ${pkgs.caddy}/bin/caddy run";
            mail.command = "${pkgs.mailhog}/bin/MailHog";
            php.command = "${php}/bin/php-fpm -F -y php-fpm.conf";
            # redis.command = "${$pks.redis}/bin/redis-server";
          };

          devShells.default = pkgs.mkShell
            {
              buildInputs = with pkgs; [
                caddy

                php
                php.packages.composer
                php.packages.php-codesniffer

                # OpenCode tools
                sqlite
                jq

                # IDE
                unstable.helix
                nodePackages.intelephense
                typescript-language-server
                vscode-langservers-extracted
              ];
            };

          checks = {
            phpstan = pkgs.stdenvNoCC.mkDerivation {
              name = "phpstan-check";
              dontBuild = true;
              doCheck = true;
              src = ./.;
              buildInputs = [ php php.packages.phpstan ];

              checkPhase = ''
                mkdir $out
                cp -r $src/* $out
                cd $out
                php install.php
                phpstan analyze --ansi # --memory-limit=256M
              '';
            };
          };
        };
    };
}
