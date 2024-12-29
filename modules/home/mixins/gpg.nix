{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.programs.gpg;
in
lib.mkMerge [
  (lib.mkIf cfg.enable {
    programs.gpg = {
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
  })
  (lib.mkIf (cfg.enable && isDarwin) {
    # The 'gpg-agent' module for 'home-manager' takes care of this, but it's
    # Linux-only.
    programs.fish.shellInit = lib.optionalString config.programs.fish.enable ''
      set -x GPG_TTY (tty)

      # TODO: replace this w/ 'nix-darwin' & 'launchd'.
      #
      # cf. https://evilmartians.com/chronicles/stick-with-security-yubikey-ssh-gnupg-macos
      set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
    '';
  })
]
