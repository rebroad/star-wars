#!/bin/sh
set -eu

mame_source=${MAME_SOURCE:?set MAME_SOURCE to a MAME checkout outside this repository}
source_repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
web_output=${WEB_OUTPUT:-$source_repo/web}
webassembly=${WEBASSEMBLY:-0}

command -v emmake >/dev/null 2>&1 || {
    echo "error: Emscripten emmake is required" >&2
    exit 2
}
cd "$mame_source"
emmake make -j2 SUBTARGET=starwars-web \
    SOURCES=src/mame/atari/starwars.cpp \
    WEBASSEMBLY="$webassembly"
mkdir -p "$web_output"
cp starwars-web.js "$web_output/"
if [ "$webassembly" = 1 ]; then
    cp starwars-web.wasm "$web_output/"
fi
printf '%s\n' "MAME browser output: $web_output (WEBASSEMBLY=$webassembly)"
