{ callPackage, python3 }:
{
  west2nix = python3.pkgs.callPackage ./package.nix { };
  mkWest2nixHook = callPackage ./hook.nix { };
}
