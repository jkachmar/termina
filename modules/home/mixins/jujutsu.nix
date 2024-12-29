{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.programs.jujutsu;
in
lib.mkIf cfg.enable (
  lib.mkMerge [
    {
      # Install 'watchman' so 'jujutsu' can use it for filesystem monitoring.
      home.packages = [ pkgs.watchman ];
      programs.jujutsu = {
        package = unstable.jujutsu;
        settings = {
          core.fsmonitor = "watchman";
          colors."commit_id prefix".bold = true;
          # FIXME: NixOS & nix-darwin both set '$PAGER' to 'less -R'.
          ui.pager = "less \-FRX";
          template-aliases."format_short_id(id)" = "id.shortest(12)";
        };
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
      programs.git.ignores = [ ".jj" ];
    })
  ]
)
