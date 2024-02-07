{ buildPythonApplication
, lib
, flit-core
, tomlkit
, pyyaml
, west
, nix-prefetch-git
}:
let
  pyproject = lib.importTOML ./pyproject.toml;
in
buildPythonApplication {
  pname = "west2nix";
  inherit (pyproject.project) version;

  format = "pyproject";

  src = ./.;

  makeWrapperArgs = [ "--prefix PATH : ${nix-prefetch-git}/bin" ];

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    tomlkit
    pyyaml
    west
  ];
}
