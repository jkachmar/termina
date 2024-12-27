{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.macos.base;
in
{
  options.profiles.macos.base = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "base profile for all darwin systems";
      default = true;
    };
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
