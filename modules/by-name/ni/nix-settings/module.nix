{ inputs, pkgs, ... }:

{
  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      allowed-users = [ "root" ];
    };
    channel.enable = false;
  };
}
