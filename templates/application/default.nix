{ stdenv
, zephyr  # from zephyr-nix
, callPackage
, cmake
, ninja
, west2nix
, gitMinimal
, lib
}:

let
  west2nixHook = west2nix.mkWest2nixHook {
    manifest = ./west2nix.toml;
  };

in
stdenv.mkDerivation {
  name = "west2nix-example";

  nativeBuildInputs = [
    (zephyr.sdk.override {
      targets = [
        "arm-zephyr-eabi"
      ];
    })
    west2nixHook
    zephyr.pythonEnv
    zephyr.hosttools-nix
    gitMinimal
    cmake
    ninja
  ];

  # Note: This should be set by the hook but it's tricky to get the ordering correct
  dontUseCmakeConfigure = true;

  src = ./.;

  westBuildFlags = [
    "-b"
    "nrf21540dk_nrf52840"
  ];

  installPhase = ''
    mkdir $out
    cp ./build/zephyr/zephyr.elf $out/
  '';
}
