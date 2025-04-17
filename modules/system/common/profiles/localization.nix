{
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.localization;
in
{
  options.profiles.localization.enable = (lib.mkEnableOption "locale & localization") // {
    default = true;
  };

  imports = [
    (lib.mkAliasOptionModule [ "profiles" "localization" "timeZone" ] [ "time" "timeZone" ])
  ];
  config = lib.mkIf cfg.enable {
    profiles.localization = {
      timeZone = lib.mkDefault "America/New_York";
    };
  };
}
