function __west2nix_setupFakeGit {
    echo Creating fake dummy git repo in "$1"

    @git@ -C "$1" init
    @git@ -C "$1" config user.email 'foo@example.com'
    @git@ -C "$1" config user.name 'Foo Bar'
    @git@ -C "$1" add -A
    @git@ -C "$1" commit -m 'Fake commit'
    @git@ -C "$1" checkout -b manifest-rev
    @git@ -C "$1" checkout --detach manifest-rev
}

function __west2nix_copyProject {
    mkdir -p $(dirname "$2")
    cp -r "$1" "$2"
    chmod +w "$2"
    __west2nix_setupFakeGit "$2"
}

function __west2nix_copyProjectsHook {
    echo "Executing __west2nix_copyProjectsHook"

    @copyProjects@
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
