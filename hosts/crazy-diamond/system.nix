{
  config,
  lib,
  ...
}: {
  imports = [
    ../../modules/system/primary-user/macos.nix
    ../../config/system/devtools.nix
    ../../config/system/nix.nix
  ];

  primary-user.home-manager = import ./user.nix;

  nix.configureBuildUsers = true;
  services.nix-daemon.enable = true;

  # 2x maxJobs = up to 2 derivations may be built in parallel
  # 2x buildCores = each derivation will be given 2 cores to work with
  nix.settings = {
    cores = lib.mkDefault 2;
    max-jobs = lib.mkDefault 2;

    # distributedBuilds = true;
    # buildMachines = [
    #   {
    #     hostName = "192.168.1.150";
    #     sshUser = "jkachmar";
    #     sshKey = "/Users/jkachmar/.ssh/id_enigma";
    #     systems = ["x86_64-linux"];
    #     maxJobs = 2;
    #   }
    # ];
  };

  ###########################################################################
  # Used for backwards compatibility, please read the changelog before
  # updating.
  #
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
