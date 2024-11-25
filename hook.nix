{ lib
, makeSetupHook
, gitMinimal
, fetchgit
}:
{ manifest
}:
let
  manifest' =
    if builtins.isPath manifest then (lib.importTOML manifest)
    else manifest;
in
makeSetupHook
{
  name = "west2nix-project-hook.sh";
  substitutions = {
    # West only considers proper git repos when discovering projects.
    # Hack around this by:
    # - Copying the project into place
    # - Instantiate a git repo
    git = lib.getExe gitMinimal;

    # Copy projects into the workspace
    copyProjects = lib.concatStringsSep "\n" (
      map
        (project:
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
          '')
        manifest'.manifest.projects
    );

    # Project path for `west init -l ...`
    path = manifest'.manifest.self.path or ".";
  };
} ./project-hook.sh
