{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) fqdn;
  cfg = config.services.homebridge;
  nginxCfg = config.services.nginx;
in {
  options.services.homebridge = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable "HomeKit support for the impatient" self-hosted bookmark manager
        with some reasonable defaults for my personal deployment with Podman &
        root on tmpfs.
      '';
    };
    port = lib.mkOption {
      type = types.int;
      readOnly = true;
      default = 8581;
      description = lib.mkDoc ''
        Homebridge UI port to forward along to the same port on the host.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # TODO: Factor default 'impermanence' root state location to its own
      # config module to share.
      environment.persistence."/state/root".directories = ["/var/lib/homebridge"];
      # NOTE: Ports & port ranges need to match up with the homebridge
      # 'config.json'
      networking.firewall = {
        allowedTCPPorts = [5353 cfg.port 51241];
        allowedTCPPortRanges = [
          {
            from = 52100;
            to = 52150;
          }
        ];
        allowedUDPPorts = [5353 cfg.port 51241];
        allowedUDPPortRanges = [
          {
            from = 52100;
            to = 52150;
          }
        ];
      };
      virtualisation.oci-containers.containers.homebridge = {
        image = "docker.io/homebridge/homebridge:latest";
        volumes = ["/var/lib/homebridge:/homebridge"];
        environment = {TZ = config.time.timeZone;};
        ports = ["${builtins.toString cfg.port}:${builtins.toString cfg.port}"];
        extraOptions = [
          "--privileged" # TODO: Set up macvlan networking to avoid host mode.
          "--net=host" # TODO: Set up macvlan networking to avoid host mode.
          "--label=io.containers.autoupdate=registry"
        ];
      };
      systemd.services.podman-homebridge.after = [
        "var-lib-homebridge.mount"
      ];
    })

    (lib.mkIf nginxCfg.enable {
      services.nginx.virtualHosts."homebridge.${fqdn}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = fqdn;
        locations."/".proxyPass = "http://localhost:${builtins.toString cfg.port}";
      };
    })
  ];
}
