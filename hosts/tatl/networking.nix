{...}: {
  networking = {
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
