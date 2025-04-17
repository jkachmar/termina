{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.homebrew;
in
{
  options.profiles.homebrew = {
    enable = (lib.mkEnableOption "homebrew & Mac App Store profile") // {
      default = true;
    };
    personal = lib.mkEnableOption "non-work applications";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      global.autoUpdate = true;
      onActivation.upgrade = true;
      casks =
        [
          "balenaetcher" # usb drive imaging
          "ghostty" # spooky terminal
          "sanesidebuttons" # better mouse navigation
        ]
        ++ lib.optionals cfg.personal [
          "calibre" # digital library
          "discord" # nerd chat
          "element" # nerdier chat
          "signal" # secret chat
          "zotero" # nerdier digital library
        ];
      # Mac App Store applications.
      #
      # NOTE: Use the `mas` CLI to search for the number associated with a
      # given application name.
      #
      # e.g. `mas search 1Password`
      masApps = lib.mkIf cfg.personal {
        "Slack" = 803453959;
        "Strongbox Pro" = 1481853033;
        "Wireguard" = 1451685025;
      };
    };
  };
}
