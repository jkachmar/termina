{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./common.nix];

  programs.fish.shellInit = lib.optionalString config.programs.fish.enable ''
    set -X GPG_TTY (tty)
  '';
}
