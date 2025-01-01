{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.jk.macos.apps;
in
{
  options.jk.macos.apps.enable = lib.mkEnableOption "my homebrew & app store environment";

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      global.autoUpdate = true;
      onActivation.upgrade = true;

      casks = [ "ghostty" ];
      # Mac App Store applications.
      #
      # NOTE: Use the `mas` CLI to search for the number associated with a given
      # application name.
      #
      # e.g. `mas search 1Password`
      masApps = {
        "Slack" = 803453959;
      };
    };
  };
}
