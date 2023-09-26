{config, ...}: {
  environment.persistence."/state/root".directories = ["/var/lib/hass"];
  networking.firewall = {
    allowedTCPPorts = [ 5353 8123 ];
    allowedUDPPorts = [ 5353 1900 ];
  };
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = ["/var/lib/hass:/config"];
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [
      "8123:8123"
      "1900:1900/udp" # SSDP
    ];
    extraOptions = [
      "--net=host"
      "--privileged"
      # "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
       "--label=\"io.containers.autoupdate=registry\""
    ];
  };
  systemd.services.podman-home-assistant.after = [
    "avahi-daemon.socket"
    "var-lib-hass.mount"
  ];
}
