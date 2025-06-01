{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.fonts;
in
{
  options.profiles.fonts.enable = (lib.mkEnableOption "user font profile") // {
    default = true;
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Icon fonts.
      emacs-all-the-icons-fonts
      font-awesome_5

      # "Actual" fonts.
      hack-font
      ibm-plex
      jetbrains-mono
      overpass

      # Various fonts with nerd symbols.
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.overpass
    ];
  };
}
