{config, ...}: {
  environment.persistence."/state/root".directories = ["/var/lib/homebridge"];
  # NOTE: Ports & port ranges need to match up with the homebridge config.json
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
    image = "homebridge/homebridge:latest";
    volumes = ["/var/lib/homebridge:/homebridge"];
    environment = {
      TZ = config.time.timeZone;
    };
    ports = ["8581:8581"];
    extraOptions = [
      "--privileged"
      "--net=host"
      # "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
      "--label=\"io.containers.autoupdate=registry\""
    ];
  };
  systemd.services.podman-homebridge.after = [
    "avahi-daemon.socket"
    "var-lib-homebridge.mount"
  ];
}
