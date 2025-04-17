{
  config,
  lib,
  ...
}:
let
  cfg = config.macos.settings;
in
{
  options.macos.settings.enable = (lib.mkEnableOption "macOS system settings") // {
    default = true;
  };

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
