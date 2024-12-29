{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.jk.gpg;
in
{
  options.jk.gpg = {
    enable = lib.mkEnableOption "my PGP environment";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.gpg = {
        enable = true;
        scdaemonSettings = {
          disable-ccid = true;
        };
      };
    })
    (lib.mkIf (cfg.enable && isDarwin) {
      # The 'gpg-agent' module for 'home-manager' takes care of this, but it's
      # Linux-only.
      #
      # TODO: replace this w/ 'nix-darwin' & 'launchd'.
      # cf. https://evilmartians.com/chronicles/stick-with-security-yubikey-ssh-gnupg-macos
      programs.fish.shellInit = lib.optionalString config.programs.fish.enable ''
        set -x GPG_TTY (tty)
        set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
      '';
    })
  ];
}
