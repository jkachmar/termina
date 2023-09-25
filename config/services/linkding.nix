{...}: {
  virtualisation.oci-containers.containers.linkding = {
    image = "sissbruecker/linkding:latest";
    volumes = ["/state/no_snapshot/linkding:/etc/linkding/data"];
    ports = ["9090:9090"];
    extraOptions = ["--label=\"io.containers.autoupdate=registry\""];
  };
}
