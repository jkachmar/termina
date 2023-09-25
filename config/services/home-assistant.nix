{config, ...}: {
  environment.persistence."/state/root".directories = ["/var/lib/hass"];
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = ["/var/lib/hass:/config"];
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [":8123"];
    extraOptions = ["--label=\"io.containers.autoupdate=registry\""];
  };
  systemd.services.podman-linkding.after = ["var-lib-hass.mount"];
}
