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
MAME_SOURCE="$mame_source" WEB_OUTPUT="$repo/web" \
    "$repo/tools/build-mame-wasm.sh"
mkdir -p "$repo/web/roms"
cp "$repo/roms-built/starwars1.zip" "$repo/web/roms/starwars.zip"

test -s "$repo/web/starwars-web.js"
test -s "$repo/web/roms/starwars.zip"
printf '%s\n' "Browser assets are ready in $repo/web"
printf '%s\n' "Run: python3 -m http.server 8000 --directory $repo/web"
printf '%s\n' "Open: http://127.0.0.1:8000/"
