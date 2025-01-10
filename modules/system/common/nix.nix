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

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix = {
        package = pkgs.lix;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          # NOTE: For some reason 'root' is a 'trusted-user' by default, but
          # not an 'allowed-user'.
          allowed-users = [ "root" ];
        };

        # Set '$NIX_PATH' entries to point to the local registry.
        nixPath = (
          builtins.map (pkgset: "${pkgset}=flake:${pkgset}") [
            "nixpkgs"
            "unstable"
          ]
        );

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
    })
    (lib.mkIf (cfg.enable && isDarwin) {
      nix = {
        # de-prioritize Nix daemon I/O priority relative to userspace stuff.
        daemonIOLowPriority = true;

        # macOS-specific config for standard 'nix' module options.
        nixPath =
          [
            "darwin=${inputs.darwin}"
          ]
          ++ lib.optionals config.jk.account.enable [
            "darwin-config=${config.jk.account.configLocation}"
          ];
        settings = {
          allowed-users = [ "@admin" ];
          trusted-users = [ "@admin" ];
        };
      };
    })
    (lib.mkIf (cfg.enable && isLinux) {
      nix = {
        settings = {
          allowed-users = [ "@wheel" ];
          trusted-users = [ "@wheel" ];
        };
      };
    })
  ];
}
