{...}: {
  services.resolved = {
    enable = true;
    fallbackDns = [ "9.9.9.9" "8.8.8.8" ];
  };

  networking = {
    # FIXME: `resolved` tries to get its DNS servers from the presently
    # configured network manager; until i set up `networkd` one basically
    # doesn't exist on a headless server such as this.
    nameservers = [ "192.168.1.150" ];
    useDHCP = false;
    interfaces = {
      enp86s0.useDHCP = true;
      wlo1.useDHCP = true;
    };

    firewall = {
      enable = true;
    };
  };
}
