{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionalAttrs optionalString;
  inherit (pkgs.buildPlatform) isDarwin;
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "${sshDir}/known_hosts";
    extraOptionOverrides = optionalAttrs isDarwin {
      IgnoreUnknown = "AddKeysToAgent,UseKeychain";
    };

    extraConfig = optionalString isDarwin ''
      AddKeysToAgent yes
      UseKeychain yes
    '';
  };
}
