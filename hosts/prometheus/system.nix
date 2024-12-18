{ config, lib, ... }:
{
  imports = [ ../../profiles/macos ];

  # 4x maxJobs = up to 4 derivations may be built in parallel
  # 4x buildCores = each derivation will be given 4 cores to work with
  nix.settings = {
    cores = lib.mkDefault 4;
    max-jobs = lib.mkDefault 4;
  };

  # TODO: sort out homebrew stuff
  homebrew.enable = lib.mkForce false;

  ids.gids.nixbld = 350;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
