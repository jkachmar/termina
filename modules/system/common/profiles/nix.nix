{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  cfg = config.profiles.nix;
in
{
  options.profiles.nix = {
    enable = (lib.mkEnableOption "nix configuration profile") // {
      default = true;
    };
    location = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.path
        lib.types.str
      ];
      description = "default location for this config; varies between NixOS & macOS";
      default = if isDarwin then "/etc/nix-darwin" else /etc/nixos;
    };
  };

  imports = [ inputs.lix-module.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.lix;
      settings = {
        experimental-features =
          [
            "flakes"
            "nix-command"
            "repl-flake"
          ]
          ++ lib.optionals isLinux [
            "cgroups"
          ];
        # NOTE: For some reason 'root' is a 'trusted-user' by default, but not
        # an 'allowed-user'; also extend 'root' privileges to the 'admin'
        # group on macOS.
        allowed-users =
          [
            "root"
          ]
          ++ lib.optionals isDarwin [
            "@admin"
          ]
          ++ lib.optionals isLinux [
            "@wheel"
          ];
        trusted-users = lib.optionals isDarwin [ "@admin" ] ++ lib.optionals isLinux [ "@wheel" ];
      };

      # Globally disable Nix channels.
      channel.enable = false;

      # Set some relevant '$NIX_PATH' entries to point to the system registry.
      nixPath =
        let
          flakes = [
            "nixpkgs"
            "unstable"
          ] ++ lib.optionals isDarwin [ "darwin" ];
        in
        (builtins.map (pkgset: "${pkgset}=flake:${pkgset}") flakes)
        ++ lib.optionals isDarwin [
          "darwin-config=${cfg.location}"
        ];

      # Pass some flake inputs through to the system registry.
      registry =
        let
          entries = [
            "nixpkgs"
            "unstable"
            "home-manager"
          ] ++ lib.optionals isDarwin [ "darwin" ];
        in
        lib.genAttrs entries (input: {
          to = {
            type = "path";
            path = inputs."${input}";
          };
        });
    };

    nixpkgs = {
      config = self.nixpkgs-config;
      overlays = [ self.overlays.stable ];
      flake = {
        setFlakeRegistry = true;
        setNixPath = true;
      };
    };
  };
}
