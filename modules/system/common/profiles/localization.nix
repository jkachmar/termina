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
      # Clickhouse sets UTC as the default time zone, which conflicts with
      # 'lib.mkDefault' here; 'mkOverride 999' is higher priority.
      timeZone = lib.mkOverride 999 "America/New_York";
    };
  };
}
