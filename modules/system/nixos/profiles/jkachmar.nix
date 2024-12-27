{
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.jkachmar;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "profiles" "jkachmar" "extraGroups" ]
      [ "users" "users" cfg.username "extraGroups" ]
    )
    (lib.mkAliasOptionModule
      [ "profiles" "jkachmar" "isNormalUser" ]
      [ "users" "users" cfg.username "isNormalUser" ]
    )
  ];

  config = lib.mkIf cfg.enable {
    profiles.jkachmar = {
      extraGroups = [ "wheel" ];
      isNormalUser = lib.mkDefault true;
    };
  };
}
