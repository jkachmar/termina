{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.jk.vcs;
in
{
  options.jk.vcs = {
    enable = lib.mkEnableOption "my VCS environment";

    name = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "my default VCS name (appears on commits)";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "git@jkachmar.com";
      description = "my default VCS email address (appears on commits)";
    };

    signing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "commit signing with gpg; defaults keys associated with vcs email";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.git = {
        enable = true;

        userName = cfg.name;
        userEmail = cfg.email;

        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.default = "simple";
          rerere.enabled = true;
        };

        # 'home-manager' is handling git config, so make sure jujutsu's state
        # directory is ignored when colocated with git repos.
        ignores = [ ".jj" ];
      };

      # Install 'watchman' so 'jujutsu' can use it for filesystem monitoring.
      home.packages = [ pkgs.watchman ];
      programs.jujutsu = {
        enable = true;
        package = unstable.jujutsu;
        settings = {
          user.name = cfg.name;
          user.email = cfg.email;

          core.fsmonitor = "watchman";
          colors."commit_id prefix".bold = true;
          template-aliases."format_short_id(id)" = "id.shortest(12)";

          # FIXME: NixOS & nix-darwin both set '$PAGER' to 'less -R'.
          ui.pager = "less \-FRX";
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.signing) {
      programs.jujutsu.settings = {
        signing = {
          sign-all = true;
          backend = "gpg";
          key = cfg.email;
        };
      };
    })
  ];
}
