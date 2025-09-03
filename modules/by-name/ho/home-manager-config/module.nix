{
  inputs,
  lib,
  unstable,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = { inherit inputs unstable; };
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
  };
}
