{ config, lib, ... }:
let
  cfg = config.services.dnscrypt-proxy2;
  piholeCfg = config.services.pihole;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = [ "/var/lib/private/dnscrypt-proxy" ];
      systemd.services.dnscrypt-proxy2.after = [ "var-lib-private-dnscrypt\\x2dproxy.mount" ];
      services.dnscrypt-proxy2 = {
        # See the upstream TOML configuration example for a documented list of
        # available settings:
        #
        # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
        settings = {
          # XXX: AFAICT there's no way to tell `dnscrypt-proxy` to prioritize one
          # server over the other.
          #
          # Ideally this could specify servers to try in order of priority so
          # Cloudflare could be set as a fallback even though I prefer Quad9.
          server_names = [ "cloudflare" ];
          fallback_resolvers = [
            "9.9.9.9:53"
            "1.1.1.1:53"
          ];
          ignore_system_dns = true;

          # Prefer DNS-Over-HTTPS and require DNSSEC verification for the
          # proxies.
          doh_servers = true;
          dnscrypt_servers = false;
          require_dnssec = true;

          # Only allow servers without filtering (PiHole takes care of this) or
          # logging.
          #
          # NOTE: This is more useful for configurations with multiple server
          # names; in my case, since Cloudflare is the only one selected, if
          # they add filtering or logging, DNS resolution will simply break.
          require_nofilter = true;
          require_nolog = true;

          # TODO: Finish figuring out IPv6 networking...
          ipv6_servers = false;

          # Source list for the information associated with entries in the
          # `server_names` config block above.
          sources = {
            # Quad9 DNS resolvers.
            quad9-resolvers = {
              urls = [ "https://www.quad9.net/quad9-resolvers.md" ];
              cache_file = "/var/lib/private/dnscrypt-proxy/quad9-resolvers.md";
              minisign_key = "RWTp2E4t64BrL651lEiDLNon+DqzPG4jhZ97pfdNkcq1VDdocLKvl5FW";
              refresh_delay = 72;
              prefix = "quad9-";
            };

            # Public DNS resolvers.
            public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                "https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                "https://download.dnscrypt.net/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "/var/lib/private/dnscrypt-proxy/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 72;
              prefix = "";
            };

            # Anonymized DNS relays.
            relays = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
                "https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md"
                "https://download.dnscrypt.net/resolvers-list/v3/relays.md"
              ];
              cache_file = "/var/lib/private/dnscrypt-proxy/relays.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 72;
              prefix = "";
            };
          };
        };
      };
    })
    (lib.mkIf piholeCfg.enable {
      # This is the address that the PiHole listens on for its DNS resolution;
      # for now it just uses the default Podman gateway IP, but it would be
      # nice to explicitly specify this as a CNI network setting.
      #
      # TODO: Look into switching to the PiHole Nix module whenever
      # https://github.com/NixOS/nixpkgs/pull/108055 whenever is
      # finished/merged.
      services.dnscrypt-proxy2.settings.listen_addresses = [
        "172.25.0.1:${builtins.toString piholeCfg.forwardPort}"
      ];
      systemd.services.podman-pihole.after = [ "dnscrypt-proxy2.service" ];
    })
  ];
}
