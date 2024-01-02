{
  config,
  lib,
  unstable,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.jujutsu;
in {
  programs.jujutsu = lib.mkIf cfg.enable {
    package = unstable.jujutsu;
    # Conditionally enable 'jj' integration for interactive shells managed
    # via home-manager.
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;

    settings = {
      user.name = config.primary-user.git.user.name;
      user.email = config.primary-user.git.user.email;
      ui.editor = "vi";
    };
  };
}
