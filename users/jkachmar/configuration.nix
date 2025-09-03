{
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
  userCfg = config.users.users.jkachmar;
in
{
  users.users.jkachmar = {
    name = "jkachmar";
    home = if isDarwin then "/Users/${userCfg.name}" else "/home/${userCfg.name}";
  };

  home-manager.users = {
    inherit (self.homeModules) jkachmar;
  };
}
