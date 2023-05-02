{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./common.nix];

  # The 'gpg-agent' module for 'home-manager' takes care of this, but it's
  # Linux-only.

  programs.fish.shellInit = lib.optionalString config.programs.fish.enable ''
    set -x GPG_TTY (tty)

    # TODO: replace this w/ 'nix-darwin' & 'launchd'.
    #
    # cf. https://evilmartians.com/chronicles/stick-with-security-yubikey-ssh-gnupg-macos
    set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';
}
