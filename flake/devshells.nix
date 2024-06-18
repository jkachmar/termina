{ ... }:
{
  perSystem =
    { inputs', pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs =
          with pkgs;
          [
            alejandra
            shellcheck
            inputs'.nixos-anywhere.packages.default
          ]
          ++ lib.optionals buildPlatform.isDarwin [ ]
          ++ lib.optionals buildPlatform.isLinux [
            inputs'.disko.packages.disko
            rng-tools
          ];
      };
    };
}
