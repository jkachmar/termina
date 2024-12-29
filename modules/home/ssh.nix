{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.jk.ssh;
in
{
  options.jk.ssh = {
    enable = lib.mkEnableOption "my SSH config";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ssh = {
        # TODO: Set catchall identity file to invoke the Yubikey flow.
        #extraConfig = ''
        #  IdentityFile=
        #'';
      };
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
