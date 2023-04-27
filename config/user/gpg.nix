{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionalString;
  inherit (lib.file) mkOutOfStoreSymlink;
  isFishEnabled = config.programs.fish.enable;
in {
  home.packages = [pkgs.gnupg];
  # XXX: cf. https://github.com/nix-community/home-manager/issues/1816
  programs.fish.shellInit = optionalString isFishEnabled ''
    set -x GPG_TTY (tty)
  '';
}
