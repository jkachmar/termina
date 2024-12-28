{
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.jkachmar;
in
{
  config = lib.mkIf cfg.enable {
    users.users."${cfg.username}" = {
      inherit (cfg) isNormalUser;
      extraGroups = cfg.extraGroups ++ [ "wheel" ];
    };
  };
}
