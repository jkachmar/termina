{
  config,
  lib,
  unstable,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.jujutsu;
in
  lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.jujutsu = {
        package = unstable.jujutsu;
        # Conditionally enable 'jj' integration for interactive shells managed
        # via home-manager.
        enableBashIntegration = config.programs.bash.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableZshIntegration = config.programs.zsh.enable;
        settings.ui.editor = "vim";
      };
    }
    # If 'git' is enabled, grab username & email address from that config.
    (lib.mkIf config.programs.git.enable {
      programs.jujutsu.settings.user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      # If 'home-manager' is handling git config then make sure jujutsu's
      # state directory is ignored when colocated with git repos.
      programs.git.ignores = [".jj"];
    })
  ])
