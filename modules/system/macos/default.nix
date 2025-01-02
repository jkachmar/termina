{
  config,
  inputs,
  lib,
  ...
}:
let
  accountCfg = config.jk.account;
in
{
  imports = [
    inputs.home.darwinModules.home-manager

    ./apps
    ./apps/personal.nix
    ./settings.nix
  ];

  environment.darwinConfig = lib.mkIf accountCfg.enable accountCfg.configLocation;
  system.stateVersion = 5;
}
