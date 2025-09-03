{ inputs, pkgs, ... }:

{
  imports = [ inputs.lix-module.nixosModules.default ];

  nix = {
    package = pkgs.lix;
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
