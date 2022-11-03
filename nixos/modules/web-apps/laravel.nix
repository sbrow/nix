# TODO: Install private shell key?
# TODO: git config via HomeManager?
{ config, hostName ? "nixos", lib, pkgs, ... }:

let
  cfg = config.services.laravel;
in
{
  options = {
    services.laravel = {
      domain = lib.mkOption {
        description = "The domain on which to serve the Laravel app.";
        type = lib.types.str;
        default = "localhost";
      };
      enable = lib.mkOption {
        description = "Whether to enable the Laravel web server";
        type = lib.types.bool;
        default = false;
      };
      root = lib.mkOption {
        description = "Path to the root directory of the app source.";
        type = lib.types.path;
        default = /var/www;
      };
      # database.connection = lib.mkOption { string mysql }
      /*
        env = lib.mkOption {
        description = "The environment to pass to Laravel.";
        default = "local";
        type = lib.types.enum [ "local" "staging" "production" ];
        };
      */
      user = lib.mkOption {
        description = "User account under which Laravel runs.";
        type = lib.types.str;
        default = "nginx";
      };
      # TODO: Support octane
      poolConfig = lib.mkOption {
        description = "Configuration for the php fpm pool";
        #        type = with lib.types; attrsOf inferred;
        type = lib.types.attrs;
        default = {
          user = cfg.user;
          group = "nginx";
          settings = {
            pm = "dynamic";
            "listen.owner" = cfg.user;
            "pm.max_children" = 5;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 1;
            "pm.max_spare_servers" = 3;
            "pm.max_requests" = 500;
          };

          phpEnv."PATH" = "/run/current-system/sw/bin";
        };
      };

      phpPackage = lib.mkOption {
        description = "The php package run laravel with.";
        type = lib.types.package;
        default = (pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.redis ]));
      };

      db.connection = lib.mkOption {
        description = "The backend to use for the database";
        type = lib.types.str;
        default = "mysql";
      };

      bashAliases.enable = lib.mkOption {
        description = "Whether to install aliases for bash";
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        cfg.phpPackage
        cfg.phpPackage.packages.composer
      ];

      services.phpfpm.phpPackage = cfg.phpPackage;
      services.phpfpm.pools."www" = cfg.poolConfig;

      services.nginx.enable = true;
      services.nginx.user = cfg.user;
      services.nginx.virtualHosts."${cfg.domain}" = {
        /*
          enableACME = false;
          forceSSL = true;
          sslCertificate = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.cert.pem";
          sslCertificateKey = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.key.pem";
        */

        root = "/${cfg.root}/public";

        locations."/".index = "index.php";
        locations."/".tryFiles = "$uri $uri/ /index.php$is_args$args";
        locations."~ \.php$".extraConfig = ''
          fastcgi_pass  unix:${config.services.phpfpm.pools."www".socket};
          fastcgi_index index.php;
        '';
      };
    }
    (lib.mkIf (cfg.db.connection == "mysql") {
      services.mysql.enable = true;
      services.mysql.package = pkgs.mysql80;
      services.mysql.ensureDatabases = [ "callsys" ];
      environment.etc."mysql/init.sql".text = ''
        CREATE USER 'homestead'@'localhost' IDENTIFIED BY 'secret';
        GRANT ALL ON callsys.* to 'homestead'@'localhost';
      '';
      services.mysql.initialScript = /etc/mysql/init.sql;
      services.mysql.ensureUsers = [
        {
          name = "vagrant";
          ensurePermissions = {
            "*.*" = "ALL PRIVILEGES";
          };
        }
      ];
    })
    (lib.mkIf (cfg.bashAliases.enalbe == true) {
      programs.bash.shellAliases = {
        h = "php artisan horizon";
        m = "php artisan migrate";
        mfs = "php artisan migrate:fresh --seed";
        mr = "php artisan migrate:rollback";
        mr1 = "php artisan migrate:rollback --step=1";
        standard-version = "yarn standard-version";
        t = "php artisan tinker";
      };
    })
  ]);
}
