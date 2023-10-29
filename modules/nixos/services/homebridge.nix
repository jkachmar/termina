{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.homebridge;
in {
  options.services.homebridge = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable "HomeKit support for the impatient" self-hosted bookmark manager
        with some reasonable defaults my own deployment with Podman & root on
        tmpfs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: Factor default 'impermanence' root state location to its own
    # config module to share.
    environment.persistence."/state/root".directories = ["/var/lib/homebridge"];
    # NOTE: Ports & port ranges need to match up with the homebridge
    # 'config.json'
    networking.firewall = {
      allowedTCPPorts = [5353 8581 51241];
      allowedTCPPortRanges = [
        {
          from = 52100;
          to = 52150;
        }
      ];
      allowedUDPPorts = [5353 8581 51241];
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
      environment = {
        TZ = config.time.timeZone;
      };
      ports = ["8581:8581"];
      extraOptions = [
        "--privileged" # TODO: Set up macvlan networking to avoid host mode.
        "--net=host" # TODO: Set up macvlan networking to avoid host mode.
        "--label=io.containers.autoupdate=registry"
      ];
    };
    systemd.services.podman-homebridge.after = [
      "avahi-daemon.socket"
      "var-lib-homebridge.mount"
    ];
  };
}
