########################################################################
# NixOS configuration options for the system's primary account holder. #
########################################################################
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkAliasDefinitions
    mkAliasOptionModule
    mkDefault
    mkIf
    ;

  cfg = config.primary-user;
in
{
  imports = [
    ./security/sudo-cmds.nix
    # OS-agnostic option aliases.
    ../shared/primary-user.nix
    # NixOS-specific option aliases.
    (mkAliasOptionModule
      [
        "primary-user"
        "initialHashedPassword"
      ]
      [
        "users"
        "users"
        cfg.name
        "initialHashedPassword"
      ]
    )
    (mkAliasOptionModule
      [
        "primary-user"
        "passwordFile"
      ]
      [
        "users"
        "users"
        cfg.name
        "passwordFile"
      ]
    )
    (mkAliasOptionModule
      [
        "primary-user"
        "extraGroups"
      ]
      [
        "users"
        "users"
        cfg.name
        "extraGroups"
      ]
    )
    (mkAliasOptionModule
      [
        "primary-user"
        "isNormalUser"
      ]
      [
        "users"
        "users"
        cfg.name
        "isNormalUser"
      ]
    )
    (mkAliasOptionModule
      [
        "primary-user"
        "openssh"
      ]
      [
        "users"
        "users"
        cfg.name
        "openssh"
      ]
    )
    (mkAliasOptionModule
      [
        "primary-user"
        "sudo-cmds"
      ]
      [
        "sudo-cmds"
        cfg.name
      ]
    )
  ];

  # Define NixOS-specific `primary-user` configuration.
  config = mkIf (cfg.name != null) {
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    # TODO: Should this use `lib.mkMerge` and _only_ specify the primary user
    # as an allowed and/or trusted user?
    nix.settings = {
      allowed-users = [
        "root"
        cfg.name
      ];
      trusted-users = [
        "root"
        cfg.name
      ];
    };

    # Keep this up-to-date with respect to the stable nixpkgs version.
    system.stateVersion = lib.mkDefault "23.05";
  };
}
