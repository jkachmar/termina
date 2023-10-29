{
  config,
  lib,
  ...
}: let
  cfg = config.services.openssh;
in
  lib.mkIf cfg.enable {
    services.openssh = {
      allowSFTP = lib.mkDefault false;

      # Stealing some "paranoid" OpenSSH configuration options.
      #
      # cf. https://christine.website/blog/paranoid-nixos-2021-07-18
      settings = {
        AllowAgentForwarding = true;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = true;
        AuthenticationMethods = "publickey";
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };

      # XXX: Default location for host keys; maybe this can come from some
      # deployment secrets manager?
      hostKeys = [
        {
          path = "/secrets/openssh/host/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/secrets/openssh/host/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  }
