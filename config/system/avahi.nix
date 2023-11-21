{...}: {
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    reflector = true;
    publish.enable = true;
  };
}
