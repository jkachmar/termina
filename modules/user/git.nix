{
  config,
  lib,
  unstable,
  ...
}:
let
  inherit (lib) types;
  cfg = config.programs.git;
in
{
  programs.git = lib.mkIf cfg.enable {
    # Assume 'git' username is the same as the account username.
    userName = lib.mkDefault config.home.username;
    # Default git email address.
    #
    # FIXME: Put this in some kind of encrypted secret to obfuscate my actual
    # got-damn email address.
    userEmail = lib.mkDefault "git@jkachmar.com";

    extraConfig = {
      core.editor = "vim";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.default = "simple";
      rerere.enabled = true;
    };
  };
}
