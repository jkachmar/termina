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

  networking.hostName = "prometheus";
  home-manager.users.jkachmar.profiles.vcs.email = "j@mercury.com";

  system = {
    primaryUser = "jkachmar";
    stateVersion = 6;
  };
}
