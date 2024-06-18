{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.networking.wireguard;
in
{
  config = lib.mkIf cfg.enable {
    # XXX: Hardened profile locks kernel modules, so attempting to call
    # 'modprobe' from the Wireguard service fails.
    boot.initrd.kernelModules = [ "wireguard" ];
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;

      # 'rp_filter' is reverse path filtering; by default it will ensure that
      # the source of the received packet belongs to the receiving interface.
      #
      #
      # NixOS' hardened profile sets this to '1', which will block data for the
      # Wireguard VPN client; setting it to '2' will only drop the packet if it
      # is not routable through any of the defined interfaces.
      #
      # cf. https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;
    };
    networking = {
      nat = {
        enable = true;
        # XXX: 'enp86s0' is the stable name for this system's onboard NIC; it
        # _must_ be kept in sync with the primary network interface!
        externalInterface = "enp86s0";
        internalInterfaces = builtins.attrNames config.networking.wireguard.interfaces;
      };
      # Wireguard listen port must also be forwarded.
      firewall.allowedUDPPorts = [ 51820 ];
      wireguard.interfaces.wg0 = {
        ips = [ "192.168.50.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/secrets/wireguard/privatekey";

        peers = [
          {
            # crazy-diamond | MacBook Pro
            publicKey = "Mi0aMgmZrZF9MDS8POWtAOgdSCyG4C0kpiAcLvz8HAs=";
            allowedIPs = [ "192.168.50.2/32" ];
          }
          {
            # purple-haze | iPhone 14 Pro
            publicKey = "U9twqSeN7eNEap4JodQf20aO+rtbBylB82RUiYuEUnc=";
            allowedIPs = [ "192.168.50.3/32" ];
          }
          {
            # wonder-of-u | iPad Mini
            publicKey = "X7KUdq+6fHFuyY81BLtKG6LUNQOmOHdtGzhDQRxC4yw=";
            allowedIPs = [ "192.168.50.4/32" ];
          }
        ];
        # This allows the wireguard server to route your traffic to the
        # internet and hence be like a VPN.
        #
        # For this to work you have to set the dnsserver IP of your router (or
        # dnsserver of choice) in your clients.
        #
        # XXX: 'enp86s0' is the stable name for this system's onboard NIC; it
        # _must_ be kept in sync with the primary network interface!
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.50.0/24 -o enp86s0 -j MASQUERADE
        '';

        # This undoes the above command
        #
        # XXX: 'enp86s0' is the stable name for this system's onboard NIC; it
        # _must_ be kept in sync with the primary network interface!
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.50.0/24 -o enp86s0 -j MASQUERADE
        '';
      };
    };

    # Wireguard should wait to start until after the 'secrets' directory has
    # been mounted (it needs to access keys).
    systemd.services.wireguard-wg0 = {
      after = [ "secrets.mount" ];
      requires = [ "secrets.mount" ];
    };
  };
}
