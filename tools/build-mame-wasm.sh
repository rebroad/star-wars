#!/bin/sh
set -eu

mame_source=${MAME_SOURCE:?set MAME_SOURCE to a MAME checkout outside this repository}
mame_build=${MAME_BUILD:-$mame_source.build}
source_repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -d "$source_repo.build" ]; then
    build_tree=$source_repo.build
elif [ -d "$source_repo.make" ]; then
    build_tree=$source_repo.make
else
    build_tree=$source_repo.build
    mkdir -p "$build_tree"
fi

command -v emmake >/dev/null 2>&1 || {
    echo "error: Emscripten emmake is required" >&2
    exit 2
}
command -v cpto >/dev/null 2>&1 || {
    echo "error: cpto is required to synchronize the repository" >&2
    exit 2
}

cpto "$source_repo" "$build_tree/star-wars"
cpto "$mame_source" "$mame_build"
mkdir -p "$build_tree/mame-wasm"
cd "$mame_build"
emmake make -j2 SUBTARGET=starwars-web \
    SOURCES=src/mame/atari/starwars.cpp \
    TARGETOS=wasm WEBASSEMBLY=1
cp starwars-web.js starwars-web.wasm "$build_tree/mame-wasm/"
printf '%s\n' "MAME WebAssembly output: $build_tree/mame-wasm"
