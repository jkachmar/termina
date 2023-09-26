{config, ...}: {
  environment.persistence."/state/root".directories = ["/var/lib/homebridge"];
  networking.firewall = {
    allowedTCPPorts = [ 5353 8581 51241 51535 ];
    allowedUDPPorts = [ 5353 8581 51241 51535 ];
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
