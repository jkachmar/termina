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
    set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';
}
