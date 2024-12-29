{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.macos.brew;
in
{
  options.profiles.macos.brew.enable = lib.mkEnableOption "homebrew management profile";

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      global.autoUpdate = true;
      onActivation.upgrade = true;
      taps = [ "homebrew/cask" ];
      casks = [
        "ghostty"
        "iterm2"
      ];
    };
  };
}
