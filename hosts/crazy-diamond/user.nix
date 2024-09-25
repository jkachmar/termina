{ config, inputs, pkgs, ... }:
{
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
    ../../profiles/user/ui.nix
    # TODO: Surely this can be abstracted behind a module or something...
    ../../config/user/gpg/macos.nix
    # SSH identity management
    # TODO: There's absolutely a better solution than this...
    ../../config/user/ssh
    ../../config/user/ssh/cofree.nix
    ../../config/user/ssh/enigma.nix
    ../../config/user/ssh/github.nix
    ../../config/user/ssh/gitlab.nix
    ../../config/user/ssh/stackage.nix
    ../../config/user/ssh/tatl.nix
  ];

  home.packages = builtins.attrValues { inherit (pkgs) colima mosh; };
  programs.neovim.enable = true;
  programs.vscode.enable = true;

  programs.emacs.enable = true;
  launchd.agents.emacsdaemon = {
    enable = true;
    config = {
      ProgramArguments = [
        "${config.programs.emacs.package}/bin/emacs"
        "--fg-daemon" # keep the daemon in the foreground for 'launchd'
      ];
      RunAtLoad = true;
    };
  };
}
