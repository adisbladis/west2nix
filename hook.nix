{
  lib,
  makeSetupHook,
  gitMinimal,
  fetchgit,
  stdenvNoCC,
  python3,
}:
{
  manifest,
}:
let
  manifest' = if builtins.isPath manifest then (lib.importTOML manifest) else manifest;
  westDeps = stdenvNoCC.mkDerivation {
    name = "west-dependencies";
    unpackPhase = "true";
    nativeBuildInputs = [
      python3.pkgs.west
      gitMinimal
    ];
    dontFixup = true;
    buildPhase =
      let
        copyProjects = lib.concatStringsSep "\n" (
          map (
            project:
            let
              path = project.path or project.name;
              src = fetchgit {
                inherit (project) url;
                inherit (project.nix) hash;
                fetchSubmodules = project.submodules or false;
                rev = project.revision;
              };
            in
            ''
              __west2nix_copyProject ${src} ${path}
            ''
          ) manifest'.manifest.projects
        );
      in
      ''
        # West only considers proper git repos when discovering projects.
        # Hack around this by:
        # - Copying the project into place
        # - Instantiate a git repo
        function __west2nix_setupFakeGit {
            echo Creating fake dummy git repo in "$1"

            git -C "$1" init
            git -C "$1" config user.email 'foo@example.com'
            git -C "$1" config user.name 'Foo Bar'
            git -C "$1" add -A
            git -C "$1" commit -m 'Fake commit'
            git -C "$1" checkout -b manifest-rev
            git -C "$1" checkout --detach manifest-rev
        }
        function __west2nix_copyProject {
            mkdir -p $(dirname "$2")
            cp -r "$1" "$2"
            chmod +w "$2"
            __west2nix_setupFakeGit "$2"
        }
        ${copyProjects}
      '';
    installPhase = ''
      rm env-vars
      mkdir -p $out
      cp -r {.,}* $out
    '';
  };
in
makeSetupHook {
  name = "west2nix-project-hook.sh";
  substitutions = {
    # Project path for `west init -l ...`
    path = manifest'.manifest.self.path or ".";
    inherit westDeps;
  };
  passthru = {
    manifest = manifest';
    inherit westDeps;
  };
} ./project-hook.sh
