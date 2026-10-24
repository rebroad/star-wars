#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mame_source=${MAME_SOURCE:-}

if [ -z "$mame_source" ]; then
    echo "error: set MAME_SOURCE to a MAME checkout" >&2
    echo "example: MAME_SOURCE=/path/to/mame tools/build-browser.sh" >&2
    exit 2
fi
if [ ! -f "$mame_source/src/mame/atari/starwars.cpp" ]; then
    echo "error: MAME_SOURCE does not contain src/mame/atari/starwars.cpp" >&2
    exit 2
fi
command -v emmake >/dev/null 2>&1 || {
    echo "error: Emscripten emmake is required; source emsdk_env.sh first" >&2
    exit 2
}

"$repo/tools/build-roms.sh"
MAME_SOURCE="$mame_source" WEB_OUTPUT="$repo/web" MAME_JOBS="${MAME_JOBS:-2}" \
    "$repo/tools/build-mame-wasm.sh"

test -s "$repo/web/mamestarwarswasm.js" || test -s "$repo/web/starwarswasm.js"
test -s "$repo/web/mamestarwarswasm.wasm" || test -s "$repo/web/starwarswasm.wasm"
test -s "$repo/web/roms.js"
test -s "$repo/web/roms.data"
test -s "$repo/web/index.html"
printf '%s\n' "Browser assets are ready in $repo/web"
printf '%s\n' "Run: python3 -m http.server 8000 --directory $repo/web"
printf '%s\n' "Open: http://127.0.0.1:8000/"
