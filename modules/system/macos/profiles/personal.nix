{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.macos.personal;
in
{
  options.profiles.macos.personal = {
    enable = lib.mkEnableOption "personal macOS machine profile";
  };
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
