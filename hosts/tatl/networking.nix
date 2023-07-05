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

  # NOTE: [systemd-networkd]
  #
  # This is a server with stable interfaces; in the interest of trying
  # something new, its network will be configured as much through
  # `systemd-networkd` as possible.
  #
  # In most cases this should be fine, and will provided added flexibility in
  # terms of being able to set unit names and control settings.
  #
  # Some modules (e.g. `services.tailscale`) depend on `useNetworkd = true` to
  # configure their own `systemd-networkd` units, so the tradeoff might not be
  # worth it.
  systemd.network = {
    enable = true;
    networks = {
      "40-enp86s0" = {
        matchConfig.Name = "enp86s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6PrivacyExtensions = "kernel";
        };
      };
    };
  };

  networking = {
    # NOTE: [systemd-networkd]
    dhcpcd.enable = false;
    useDHCP = false;
    useNetworkd = false;

    firewall = {
      enable = true;
    };
  };
}
