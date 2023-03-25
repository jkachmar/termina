{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionalAttrs optionalString;
  inherit (pkgs.buildPlatform) isDarwin;
  sshConfigDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "${sshConfigDir}/known_hosts";
    matchBlocks = {
      "192.168.1.150" = {
        hostname = "192.168.1.150";
        user = config.home.username;
        identityFile = ["${sshConfigDir}/id_enigma"];
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = ["${sshConfigDir}/id_github"];
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = ["${sshConfigDir}/id_gitlab"];
      };

      "build.stackage.org" = {
        hostname = "build.stackage.org";
        user = "curators";
        identityFile = ["${sshConfigDir}/id_rsa_stackage"];
      };
    };

    extraOptionOverrides = optionalAttrs isDarwin {
      IgnoreUnknown = "AddKeysToAgent,UseKeychain";
    };

    extraConfig = optionalString isDarwin ''
      AddKeysToAgent yes
      UseKeychain yes
    '';
  };
}
