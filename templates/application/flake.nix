{
  description = "A project built with west & west2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Customize the version of Zephyr used by the flake here
    zephyr.url = "github:zephyrproject-rtos/zephyr/v3.5.0";
    zephyr.flake = false;

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    zephyr-nix.url = "github:adisbladis/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
    zephyr-nix.inputs.zephyr.follows = "zephyr";

    west2nix.url = "github:adisbladis/west2nix";
    west2nix.inputs.nixpkgs.follows = "nixpkgs";
    west2nix.inputs.zephyr-nix.follows = "zephyr-nix";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: (
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        callPackage = pkgs.newScope (pkgs // {
          zephyr = inputs.zephyr-nix.packages.${system};
          west2nix = callPackage inputs.west2nix.lib.mkWest2nix { };
        });
      in
      {
        packages.default = callPackage ./default.nix { };
        devShells.default = callPackage ./shell.nix { };
      }
    ));
}
