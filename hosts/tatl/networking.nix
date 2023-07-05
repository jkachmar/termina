{lib, ...}: {
  # Use `systemd-networkd`, but do not rely on the `networking.interfaces`
  # module to set up their units.
  #
  # The reason for setting `networking.useNetworkd` in spite of this is that
  # there are other modules for which that option controls whether they
  # generate `systemd-networkd` units (e.g. `services.tailscale`).
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.useNetworkd = true;
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

  # The firewall gets its own section, even if it's very small right now.
  networking.firewall.enable = true;
}
