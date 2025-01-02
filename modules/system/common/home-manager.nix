{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  accountCfg = config.jk.account;
  cfg = config.jk.home-manager;
in
{
  options.jk.home-manager = {
    enable = lib.mkEnableOption "my home-manager configuration";

    configPath = lib.mkOption {
      type = lib.types.path;
      description = "path to my home-manager configuration";
    };
  };

  imports = [
    (lib.mkAliasOptionModule
      [ "jk" "home-manager" "config" ]
      [ "home-manager" "users" accountCfg.username ]
    )
  ];

  config = lib.mkIf cfg.enable {
    jk.home-manager.config = import cfg.configPath;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs unstable;
      };
    };
  };
}
