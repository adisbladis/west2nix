function __west2nix_copyProjectsHook {
    echo "Executing __west2nix_copyProjectsHook"

    cp -r --no-preserve=mode @westDeps@/* .
}


function __west2nix_configureHook {
    echo "Executing __west2nix_configureHook"

    west init -l @path@
    cd @path@
}

function __west2nix_buildPhase {
    echo "Executing __west2nix_buildPhase"

    runHook preBuild
    west build $westBuildFlags
    runHook postBuild
}

postConfigureHooks+=(__west2nix_copyProjectsHook)

if [ -z "${dontUseWestConfigure-}" ] && [ -z "${configurePhase-}" ]; then
    echo "Using __west2nix_configureHook"
    postConfigureHooks+=(__west2nix_configureHook)
fi

if [ -z "${dontUseWestBuild-}" ] && [ -z "${buildPhase-}" ]; then
    echo "Using __west2nix_buildPhase"
    buildPhase=__west2nix_buildPhase
fi
