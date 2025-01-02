{
  imports = [
    ../../modules/system/common
    ../../modules/system/macos
  ];
  jk = {
    account.enable = true;
    nix.enable = true;
    macos.apps.enable = true;
    macos.settings.enable = true;
    utils.enable = true;

    home-manager = {
      enable = true;
      configPath = ./home.nix;
    };
  };
}
