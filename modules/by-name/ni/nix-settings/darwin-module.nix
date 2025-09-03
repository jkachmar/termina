{ lib, ... }:
{
  nix = {
    settings = {
      allowed-users = [ "@admin" ];
      trusted-users = [ "@admin" ];
    };

    # see '//modules/by-name/ni/nix-path'
    generateRegistryFromInputs = lib.mkDefault true;
    generateNixPathFromInputs = lib.mkDefault true;
  };
}
