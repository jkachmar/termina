{
  config,
  lib,
  self,
  ...
}:

{
  imports = [
    # my personal user declaration & associated home-manager config.
    self.darwinModules.jkachmar
  ];

  networking.hostName = "moros";
  system = {
    primaryUser = "jkachmar";
    stateVersion = 6;
  };

  profiles = {
    darwin.apps.personal = true;
  };
}
