{ config, lib, pkgs, ... }:

lib.mkIf config.programs.doom-emacs.enable {
  programs.doom-emacs = {
    doomDir = ../../doom;
    emacs = pkgs.emacs;
  };
}
