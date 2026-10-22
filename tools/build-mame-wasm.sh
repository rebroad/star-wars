#!/bin/sh
set -eu

mame_source=${MAME_SOURCE:?set MAME_SOURCE to a MAME checkout outside this repository}
source_repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
web_output=${WEB_OUTPUT:-$source_repo/web}
webassembly=${WEBASSEMBLY:-1}
make_jobs=${MAME_JOBS:-2}
subtarget=${MAME_SUBTARGET:-starwarswasm}
driver=${MAME_DRIVER:-starwars}
mame_config=${MAME_CONFIG:-release32}

command -v emmake >/dev/null 2>&1 || {
    echo "error: Emscripten emmake is required" >&2
    exit 2
}
cd "$mame_source"
if [ "$webassembly" = 1 ]; then
    ldopts='-s FORCE_FILESYSTEM=1 -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=24MB -Oz -s WARN_ON_UNDEFINED_SYMBOLS=0'
else
    ldopts='-s FORCE_FILESYSTEM=1 -s WARN_ON_UNDEFINED_SYMBOLS=0'
fi
emmake make -j"$make_jobs" \
    SUBTARGET="$subtarget" \
    DRIVERS="$driver" \
    WEBASSEMBLY="$webassembly" \
    TOOLS=0 REGENIE=1 NOWERROR=1 \
    SYMBOLS=0 SYMLEVEL=0 STRIP_SYMBOLS=1 NO_OPENGL=1 \
    config="$mame_config" LDOPTS="$ldopts"
mkdir -p "$web_output"
cp "$subtarget.js" "$web_output/starwars-web.js"
if [ "$webassembly" = 1 ]; then
    cp "$subtarget.wasm" "$web_output/starwars-web.wasm"
fi
printf '%s\n' "MAME browser output: $web_output (target=$subtarget WEBASSEMBLY=$webassembly)"
