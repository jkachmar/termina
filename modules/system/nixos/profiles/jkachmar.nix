{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.jkachmar;
in
{
  options.profiles.jkachmar = {
    enable = (lib.mkEnableOption "jkachmar's profile") // {
      default = true;
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "my primary account's username";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.username} = {
      name = cfg.username;
      uid = 1000;
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      hashedPassword = "$y$j9T$tKbi4gllRzzbgh2p1Wd6N/$Pc0Ae3q81nXmKV3GsFIIbC345Rmf4KZTDjrsw982Lj3";
      openssh.authorizedKeys.keys = [
        # yubikey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZJVgzxzU87/KHzc8u+RZot1/CHyW85zSC5jdlbDDUx openpgp:0xAAF3634A"
      ];
    };
    users.groups.${cfg.username}.gid = 1000;
    nix.settings = {
      allowed-users = [ "jkachmar" ];
      trusted-users = [ "jkachmar" ];
    };
  };
}
