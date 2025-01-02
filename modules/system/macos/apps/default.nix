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
    };
  };
}
