{
  imports = [
    ../../modules/system/shared
    ../../modules/system/macos
  ];
  jk = {
    macos.apps.enable = true;
    macos.apps.personal.enable = true;
    macos.settings.enable = true;
  };
  profiles = {
    jkachmar = {
      enable = true;
      home-manager = import ./home.nix;
    };
  };
}
