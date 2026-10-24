#!/bin/sh
set -eu

mame_source=${MAME_SOURCE:?set MAME_SOURCE to a MAME checkout outside this repository}
source_repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
web_output=${WEB_OUTPUT:-$source_repo/web}
make_jobs=${MAME_JOBS:-2}
rom_archive=${MAME_ROM_PATH:-$source_repo/roms-built/starwars1.zip}
source_include="-I$mame_source/src -I$mame_source/3rdparty/zlib -DVVF_STATS=0 -Dprint_color_stats\\(...\\)=\\(\\(void\\)0\\)"

command -v emmake >/dev/null 2>&1 || {
    echo "error: Emscripten emmake is required" >&2
    exit 2
}
if [ ! -x "$mame_source/build_web.sh" ]; then
    echo "error: MAME_SOURCE/build_web.sh is required" >&2
    exit 2
fi
if [ ! -s "$rom_archive" ]; then
    echo "error: ROM archive is missing: $rom_archive" >&2
    exit 2
fi

# Let the fork's maintained web build script own Emscripten flags, generated
# HTML, and file_packager output. This wrapper supplies the reproducible ROM
# archive and copies the standard preload artifacts into this repository.
MAME_ROM_PATH="$rom_archive" MAME_GAME=starwars1 \
    CFLAGS="${CFLAGS:-} $source_include" \
    CXXFLAGS="${CXXFLAGS:-} $source_include" \
    "$mame_source/build_web.sh" \
    -no-server -no-compress -includeroms --jobs "$make_jobs"

mame_web_output=${MAME_WEB_OUTPUT:-$mame_source/webdist}
artifact_base=starwarswasm
if [ ! -s "$mame_web_output/$artifact_base.js" ] && [ -s "$mame_web_output/mame$artifact_base.js" ]; then
    artifact_base="mame$artifact_base"
fi
mkdir -p "$web_output"
for artifact in index.html "$artifact_base.js" "$artifact_base.wasm" roms.js roms.data; do
    if [ ! -s "$mame_web_output/$artifact" ]; then
        echo "error: MAME web artifact is missing: $mame_web_output/$artifact" >&2
        exit 1
    fi
    cp "$mame_web_output/$artifact" "$web_output/$artifact"
done

printf '%s\n' "MAME browser output: $web_output (standard build_web.sh preload flow)"
