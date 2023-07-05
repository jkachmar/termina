{lib, ...}: {
  services.resolved = {
    enable = true;
    fallbackDns = [ "9.9.9.9" "8.8.8.8" ];
    # NOTE: [stub-resolver]
    extraConfig = ''
      DNSStubListener=no
    '';
  };
  # NOTE: [stub-resolver]
  #
  # DNS is being handled by a pretty miserable combination of PiHole &
  # dnscrypt-proxy; let's not add the `systemd-resolved` stub resolver to it.
  environment.etc."resolv.conf".source =
    lib.mkForce  "/run/systemd/resolve/resolv.conf";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useNetworkd = true;
    # This server is wired in, we only care about a single interface.
    interfaces.enp86s0.useDHCP = true;

    firewall = {
      enable = true;
    };
  };
}
