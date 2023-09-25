{...}: {
  environment.persistence."/state/root".directories = ["/var/lib/linkding"];
  virtualisation.oci-containers.containers.linkding = {
    image = "sissbruecker/linkding:latest";
    volumes = ["/var/lib/linkding:/etc/linkding/data"];
    ports = ["9090:9090"];
    extraOptions = ["--label=\"io.containers.autoupdate=registry\""];
  };
  systemd.services.podman-linkding.after = ["var-lib-linkding.mount"];
}
