{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin isLinux;
  cfg = config.jk.nix;
in
{
  options.jk.nix.enable = lib.mkEnableOption "my global nix configuration";

  imports = [ inputs.lix-module.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.lix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
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
        trusted-users =
          [
            "root"
          ]
          ++ lib.optionals isDarwin [
            "@admin"
          ]
          ++ lib.optionals isLinux [
            "@wheel"
          ];
      };

      # Set '$NIX_PATH' entries to point to the local registry.
      nixPath =
        (builtins.map (pkgset: "${pkgset}=flake:${pkgset}") [
          "nixpkgs"
          "unstable"
        ])
        ++ lib.optionals isDarwin [
          "darwin=${inputs.darwin}"
        ] ++ lib.optionals (isDarwin && config.jk.account.enable) [
          "darwin-config=${config.jk.account.configLocation}"
        ];

      channel.enable = false; # Use flakes for everything!
      registry = {
        nixpkgs.to = {
          type = "path";
          path = inputs.nixpkgs;
        };
        unstable.to = {
          type = "path";
          path = inputs.unstable;
        };
      };
    };

    nixpkgs = {
      config = self.nixpkgs-config;
      overlays = [ self.overlays.stable ];
    };
  };
}
