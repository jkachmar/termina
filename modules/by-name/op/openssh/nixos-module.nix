{ config, lib, ... }:
let
  cfg = config.services.openssh;
in
{
  services.openssh = {
    allowSFTP = lib.mkDefault false;

    # Stealing some "paranoid" OpenSSH configuration options.
    #
    # cf. https://christine.website/blog/paranoid-nixos-2021-07-18
    settings = lib.mkIf cfg.enable {
      AllowAgentForwarding = true;
      AllowStreamLocalForwarding = false;
      AllowTcpForwarding = true;
      AuthenticationMethods = "publickey";
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;

      # Use key exchange algorithms recommended by 'nixpkgs#ssh-audit'.
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
  };
}
