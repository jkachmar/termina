{
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.localization;
in

{
  imports = [
    (lib.mkAliasOptionModule [ "profiles" "localization" "locale" ] [ "i18n" "defaultLocale" ])
    (lib.mkAliasOptionModule [ "profiles" "localization" "keyMap" ] [ "console" "keyMap" ])
  ];

  config = lib.mkIf cfg.enable {
    profiles.localization = {
      keyMap = lib.mkDefault "us";
    };

    i18n =
      let
        inherit (cfg) locale;
      in
      {
        extraLocaleSettings = {
          LC_ADDRESS = locale;
          LC_IDENTIFICATION = locale;
          LC_MEASUREMENT = locale;
          LC_MONETARY = locale;
          LC_NAME = locale;
          LC_NUMERIC = locale;
          LC_PAPER = locale;
          LC_TELEPHONE = locale;
          LC_TIME = locale;
        };
      };
  };
}
