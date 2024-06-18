{ config, lib, ... }:
{
  imports = [ ../../profiles/macos ];

  homebrew.casks = [ "steam" ];

  # 2x maxJobs = up to 2 derivations may be built in parallel
  # 2x buildCores = each derivation will be given 2 cores to work with
  nix.settings = {
    cores = lib.mkDefault 2;
    max-jobs = lib.mkDefault 2;
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
