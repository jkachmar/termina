{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.pihole;
  nginxCfg = config.services.nginx;

  inherit (config.networking) domain;
in {
  options.services.pihole = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable the PiHole adblocking DNS resolver with some reasonable defaults
        for my personal deployment with Podman & root on tmpfs.
      '';
    };
    ip = lib.mkOption {
      type = types.str;
      default = "172.25.0.2";
      description = lib.mkDoc ''
        PiHole container IP address; make sure this is
      '';
    };
    port = lib.mkOption {
      type = types.int;
      default = 7000;
      description = lib.mkDoc ''
        Host port to forward to port 80 in the PiHole container; typically used
        to reverse proxy the admin UI.
      '';
    };
    forwardPort = lib.mkOption {
      type = types.int;
      default = 5053;
      description = lib.mkDoc ''
        Gateway port to forward DNS requests to; typically set to whatever
        'dnscrypt-proxy' is using to listen on the container network.
      '';
    };
    fqdn = lib.mkOption {
      type = types.str;
      readOnly = true;
      default = "pihole.${config.networking.fqdn}";
      description = ''
        Fully qualified domain name for this PiHole service.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = ["/etc/pihole"];
      systemd.services.podman-pihole.after = ["etc-pihole.mount"];

      networking.firewall = {
        # Allow clients to make requests on port 53.
        allowedTCPPorts = [53];
        allowedUDPPorts = [53];
        # Open up ports on the "podman0" bridge network.
        #
        # The NixOS firewall is conservative by default, so these ports must be
        # explicitly allowed in order for the PiHole to listen on `5053` (which
        # should be configured to supply local DNS resolution from
        # `dnscrypt-proxy`) .
        interfaces.podman0 = {
          allowedTCPPorts = [cfg.forwardPort];
          allowedUDPPorts = [cfg.forwardPort];
        };
      };

      virtualisation.oci-containers.containers.pihole = {
        image = "docker.io/pihole/pihole:latest";
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "${builtins.toString cfg.port}:80"
        ];
        volumes = [
          "/etc/pihole/pihole:/etc/pihole/"
          "/etc/pihole/dnsmasq.d:/etc/dnsmasq.d/"
        ];
        # TODO: Set `dnscrypt-proxy` resolver using an environment variable.
        environment = {
          # TODO: Retrieve this from a config that sets up the podman network.
          DNS1 = "172.25.0.1#${builtins.toString cfg.forwardPort}";
          REV_SERVER = "true";
          REV_SERVER_TARGET = "192.168.0.1"; # Router IP.
          REV_SERVER_CIDR = "192.168.0.0/16";
          TZ = config.time.timeZone;
          PROXY_LOCATION = "pihole";
          VIRTUAL_HOST = cfg.fqdn;
          # TODO: Change this to something secure, obviously.
          WEBPASSWORD = "hunter2";
        };
        extraOptions = [
          "--ip=${cfg.ip}"
          "--dns=127.0.0.1"
          "--dns=9.9.9.9"
          "--label=io.containers.autoupdate=registry"
        ];
        workdir = "/etc/pihole";
        autoStart = true;
      };
    })
    (lib.mkIf nginxCfg.enable {
      services.nginx.virtualHosts."${cfg.fqdn}" = {
        # forceSSL = true;
        # useACMEHost = domain;
        locations."/".proxyPass = "http://localhost:${builtins.toString cfg.port}";
      };
    })
  ];
}
