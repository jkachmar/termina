{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) fqdn;
  cfg = config.services.linkding;
  nginxCfg = config.services.nginx;
in {
  options.services.linkding = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable the linkding self-hosted bookmark manager with some reasonable
        defaults for my personal deployment with Podman & root on tmpfs.
      '';
    };
    port = lib.mkOption {
      type = types.int;
      readOnly = true;
      default = 9090;
      description = lib.mkDoc ''
        Linkding UI port to forward along to the same port on the host.
      '';
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = ["/var/lib/linkding"];
      systemd.services.podman-linkding.after = ["var-lib-linkding.mount"];

      virtualisation.oci-containers.containers.linkding = {
        image = "docker.io/sissbruecker/linkding:latest";
        volumes = ["/var/lib/linkding:/etc/linkding/data"];
        ports = ["${builtins.toString cfg.port}:${builtins.toString cfg.port}"];
        extraOptions = ["--label=io.containers.autoupdate=registry"];
        environment = {
          LD_SUPERUSER_NAME = "jkachmar";
          LD_SUPERUSER_PASSWORD = "hunter2"; # TODO: Change this, obviously...
        };
      };
    })

    (lib.mkIf nginxCfg.enable {
      services.nginx.virtualHosts."linkding.${fqdn}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = fqdn;
        locations."/".proxyPass = "http://localhost:${builtins.toString cfg.port}";
      };
    })
  ];
}
