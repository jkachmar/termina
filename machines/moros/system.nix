{
  imports = [
    ../../modules/system/shared
    ../../modules/system/macos
  ];
  profiles = {
    jkachmar = {
      enable = true;
      home-manager = import ./home.nix;
    };
    macos = {
      brew.enable = true;
      personal.enable = true;
    };
  };
  system.stateVersion = 5;
}
