{...}: {
  services.resolved = {
    enable = true;
    fallbackDns = [ "9.9.9.9" "8.8.8.8" ];
  };

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;

    useNetworkd = true;
    interfaces = {
      enp86s0.useDHCP = true;
      # wlo1.useDHCP = false;
    };

    firewall = {
      enable = true;
    };
  };
}
