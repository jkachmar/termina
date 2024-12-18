{ ... }:
{
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
    ../../profiles/user/ui.nix
    # TODO: Surely this can be abstracted behind a module or something...
    ../../config/user/gpg/macos.nix
  ];

  programs.neovim.enable = true;
  programs.vscode.enable = true;

  # programs.emacs.enable = true;
  # launchd.agents.emacsdaemon = {
  #   enable = true;
  #   config = {
  #     ProgramArguments = [
  #       "${config.programs.emacs.package}/bin/emacs"
  #       "--fg-daemon" # keep the daemon in the foreground for 'launchd'
  #     ];
  #     RunAtLoad = true;
  #   };
  # };
}
