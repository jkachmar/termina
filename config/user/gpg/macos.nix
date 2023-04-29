{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./common.nix];

  programs.fish.shellInit = lib.optionalString config.programs.fish.enable ''
    set -x GPG_TTY (tty)
  '';
}
