{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    # dolt.url = "github:sbrow/dolt";
    # phps.url = "github:fossar/nix-phps";
    # phps.inputs.nixpkgs.follows = "nixpkgs";

    sbrow.url = "github:sbrow/nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, /* phps, */ process-compose-flake, sbrow }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
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
              ; xdebug 3
              xdebug.mode=debug
              xdebug.client_port=9000

              ; xdebug 2
              xdebug.remote_enable=1
            '';
          };
        in
        {
          formatter = pkgs.nixpkgs-fmt;

          process-compose.default.settings.processes = {
            web.command = "sudo ${pkgs.caddy}/bin/caddy run";
            mail.command = "${pkgs.mailhog}/bin/MailHog";
            php.command = "${php}/bin/php-fpm -F -y php-fpm.conf";
            #php.command = "${php} artisan octane:start --watch";
            # redis.command = "${$pks.redis}/bin/redis-server";
            # db.command = "${doltPkg}/bin/dolt sql-server --config dolt.yml";
            # worker.command = php artisan horizon;
            # schedule.command = php artisan schedule:work;
          };

          devShells.default = pkgs.mkShell
            {
              buildInputs = with pkgs; [
                caddy

                php
                php.packages.composer
                php.packages.phpcbf
                php.packages.phpcs
              ];
            };
        };
    };
}
