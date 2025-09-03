{
  lib,
  flake-parts-lib,
  moduleLocation,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    toString
    types
    literalExpression
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      darwinConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Instantiated nix-darwin configurations. Used by `darwin-rebuild`.

          `darwinConfigurations` is for specific machines. If you want to expose
          reusable configurations, add them to [`darwinModules`](#opt-flake.darwinModules)
          in the form of modules (no `lib.darwinSystem`), so that you can reference
          them in this or another flake's `darwinConfigurations`.
        '';
        example = literalExpression ''
          {
            my-machine = inputs.nixpkgs.lib.darwinSystem {
              # system is not needed with freshly generated hardware-configuration.nix
              # system = "aarch64-darwin";  # or set nixpkgs.hostPlatform in a module.
              modules = [
                ./my-machine/darwin-configuration.nix
                config.darwinModules.my-module
              ];
            };
          }
        '';
      };
      darwinModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
        apply = mapAttrs (
          k: v: {
            _class = "darwin";
            _file = "${toString moduleLocation}#darwinModules.${k}";
            imports = [ v ];
          }
        );
        description = ''
          Darwin modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
