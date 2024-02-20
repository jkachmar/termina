{
  config,
  lib,
  ...
}: let
  inherit (config.networking) fqdn;
  inherit (lib) types;
  cfg = config.security.acme;
  # FIXME: Put this in some kind of encrypted secret to obfuscate my actual
  # got-damn email address.
  email = "me@jkachmar.com";
in {
  options.security.acme = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable ACME DNS-01 challenges for this host's FQDN and all subdomains
        associated with it.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.persistence."/state/root".directories = ["/var/lib/acme"];
    # NOTE: 'acme-fixperms.service' runs before any of the cert renewal
    # services kick off, so it should run after that mount point is up.
    systemd.services.acme-fixperms.after = ["var-lib-acme.mount"];

    security.acme = {
      acceptTerms = true;
      # Do not install self-signed certs initially; this appears to be
      # incompatible with nginx OCSP stapling & can create a race condition
      # upon reboot.
      preliminarySelfsigned = false;

      defaults = {
        # TODO: move this into secrets
        inherit email;
        credentialsFile = "/secrets/cloudflare/acme.env";
        dnsProvider = "cloudflare";
        # Use Cloudflare's DNS resolver rather than the system-provided one to
        # ensure that everything propagates as quickly as possible.
        extraLegoFlags = ["--dns.resolvers=1.1.1.1:53"];
      };

      certs."${fqdn}".extraDomainNames = ["*.${fqdn}"];
    };
  };
}
