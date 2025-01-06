{
  imports = [ ../../modules/home ];
  jk = {
    account.enable = true;
    fonts.enable = true;
    utils.enable = true;
    gpg.enable = true;
    ssh.enable = true;
    vcs = {
      enable = true;
      email = "j@mercury.com";
      signing = true;
    };
  };
}
