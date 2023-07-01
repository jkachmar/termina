{lib, ...}: {
  services.openssh = {
    enable = true;
    allowSFTP = lib.mkDefault false;

    # Stealing some "paranoid" OpenSSH configuration options.
    #
    # cf. https://christine.website/blog/paranoid-nixos-2021-07-18
    settings = {
      AllowAgentForwarding = false;
      AllowStreamLocalForwarding = false;
      AllowTcpForwarding = true;
      AuthenticationMethods = "publickey";
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };

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
