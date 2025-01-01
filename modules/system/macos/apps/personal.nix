{
  config,
  lib,
  ...
}:
let
  cfg = config.jk.macos.apps.personal;
in
{
  options.jk.macos.apps.personal.enable =
    lib.mkEnableOption "macOS applications for my personal machines";

  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "balenaetcher" # USB drive imager.
        "calibre" # Digital library.
        "discord" # Nerd chat.
        "element" # Nerdier chat.
        "signal" # Secret chat.
        "zotero" # Research paper catalog & organizer.
      ];
      masApps = {
        "Strongbox Pro" = 1481853033;
        "Wireguard" = 1451685025;
      };
    };
  };
}
