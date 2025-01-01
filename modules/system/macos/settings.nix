{
  config,
  lib,
  ...
}:
let
  cfg = config.jk.macos.settings;
in
{
  options.jk.macos.settings.enable = lib.mkEnableOption "my default macOS system settings";

  config = lib.mkIf cfg.enable {
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      defaults = {
        dock = {
          autohide = true;
          mru-spaces = false; # don't reorganize virtual desktop locations
          orientation = "right";
          show-recents = false;
          tilesize = 48;
        };
        NSGlobalDomain = {
          # Disable autocorrect.
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;

          # Don't hide scrollbars.
          AppleShowScrollBars = "Always";
        };
      };
    };
  };
}
