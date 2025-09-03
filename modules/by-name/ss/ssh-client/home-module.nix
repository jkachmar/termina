{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.ssh;
in
{
  options.profiles.ssh = {
    enable = lib.mkEnableOption "SSH user profile";
    yubikey = lib.mkEnableOption "yubikey identity file";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ssh.enable = true;
    })
    (lib.mkIf cfg.yubikey {
      programs.ssh.extraConfig = ''
        IdentityFile=~/.ssh/yubikey.pub
      '';
    })
    (lib.mkIf (cfg.enable && isDarwin) {
      programs.ssh = {
        extraConfig = ''
          AddKeysToAgent yes
          UseKeychain yes
        '';
        extraOptionOverrides = {
          IgnoreUnknown = "AddKeysToAgent,UseKeychain";
        };
      };
    })
  ];
}
