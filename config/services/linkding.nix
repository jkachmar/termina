{...}: {
  environment.persistence."/state/root".directories = ["/var/lib/linkding"];
  virtualisation.oci-containers.containers.linkding = {
    image = "sissbruecker/linkding:latest";
    volumes = ["/var/lib/linkding:/etc/linkding/data"];
    ports = ["9090:9090"];
    extraOptions = ["--label=\"io.containers.autoupdate=registry\""];
    environment = {
      LD_SUPERUSER_NAME = "jkachmar";
      LD_SUPERUSER_PASSWORD = "hunter2";
    };
  };
  systemd.services.podman-linkding.after = ["var-lib-linkding.mount"];
}
