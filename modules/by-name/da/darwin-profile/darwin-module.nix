{ config, lib, ... }:
let
  cfg = config.profiles.darwin;
in
{
  options.profiles.darwin = {
    enable = lib.mkEnableOption "darwin system profile";
  };

  config = lib.mkIf cfg.enable {
    homebrew.enable = lib.mkDefault true;
    system = {
      keyboard = {
        enableKeyMapping = lib.mkDefault true;
        remapCapsLockToControl = lib.mkDefault true;
      };
      defaults = {
        dock = {
          autohide = lib.mkDefault true;
          mru-spaces = lib.mkDefault false; # don't reorganize virtual desktop locations
          orientation = lib.mkDefault "right";
          show-recents = lib.mkDefault false;
          tilesize = lib.mkDefault 48;
        };
        NSGlobalDomain = {
          # Disable autocorrect.
          NSAutomaticCapitalizationEnabled = lib.mkDefault false;
          NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticPeriodSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;

          # Don't hide scrollbars.
          AppleShowScrollBars = lib.mkDefault "Always";
        };
      };
    };
  };
}
