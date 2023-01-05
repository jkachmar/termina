{
  config,
  pkgs,
  unstable,
  ...
}: {
  imports = [
    ./cli.nix
    ./neovim
    ./nix.nix
    ./nixpkgs.nix
  ];

  home.packages =
    (with pkgs; [
      starship # XXX: unclear why it's necessary to manually install this...
    ])
    ++ (with unstable; []);

  programs = {
    # Allow 'home-manager' to manage its own install.
    home-manager.enable = true;

    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;

    bat = {
      enable = true;
      config.theme = "ansi";
    };

    htop = {
      enable = true;
      settings = {
        hide_userland_threads = true;
        highlight_base_name = true;
        show_program_path = false;
        tree_view = true;
        vim_mode = true;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      # Conditionally enable direnv integration for shells that home-manager manages.
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };

    git = {
      enable = true;
      extraConfig = {
        core.editor = "vim";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.default = "simple";
        rerere.enabled = true;
      };
    };

    helix = {
      enable = true;
      package = unstable.helix;
      settings = {
        theme = "gruvbox_light";

        editor = {
          color-modes = true;
          rulers = [80];
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
        };
      };

      languages = [
        {
          name = "nix";
          auto-format = false;
          formatter.command = "alejandra";
          formatter.args = ["--quiet"];
        }
      ];
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        username.show_always = true;
      };

      # Conditionally enable starship integration for shells that home-manager manages.
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
