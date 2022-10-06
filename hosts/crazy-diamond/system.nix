{
  config,
  lib,
  ...
}: {
  imports = [
    ../../modules/system/primary-user/macos.nix
    ../../config/system
  ];

  # TODO: Check with others on what makes for good tuning here...
  #
  # For now:
  #   - 2x maxJobs = up to 2 derivations may be built in parallel
  #   - 2x buildCores = each derivation will be given 2 cores to work with
  nix = {
    buildCores = lib.mkDefault 2;
    maxJobs = lib.mkDefault 2;

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "10.0.1.150";
        sshUser = "jkachmar";
        sshKey = "/Users/jkachmar/.ssh/id_enigma";
        systems = ["x86_64-linux"];
        maxJobs = 2;
      }
    ];
  };

  # TODO: Look up what these do lol.
  services.nix-daemon.enable = true;
  users.nix.configureBuildUsers = true;

  ###########################################################################
  # Used for backwards compatibility, please read the changelog before
  # updating.
  #
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
