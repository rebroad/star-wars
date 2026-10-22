#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
prefix=${PREFIX:-/var/tmp}
tool_root=${STAR_WARS_TOOL_ROOT:-$prefix/tmp/star-wars-tools}
source_alias=$prefix/tmp/swsrc
vector_prefix=$prefix/tmp/swvector
output=${ROM_OUTPUT:-$repo/roms-built/starwars1}

mac69=${MAC69:-$tool_root/macxx/mac69}
llf=${LLF:-$tool_root/llf/llf}

bootstrap() {
    command -v git >/dev/null 2>&1 || { echo "error: git is required to bootstrap tools" >&2; exit 2; }
    mkdir -p "$tool_root"
    if [ ! -x "$mac69" ]; then
        git clone --depth 1 https://github.com/DaveShepperd/macxx "$tool_root/macxx"
        make -C "$tool_root/macxx" -f Makefile.linux mac69
    fi
    if [ ! -x "$llf" ]; then
        git clone --depth 1 https://github.com/DaveShepperd/llf "$tool_root/llf"
        make -C "$tool_root/llf" -f Makefile.linux
    fi
}

if [ ! -x "$mac69" ] || [ ! -x "$llf" ]; then
    bootstrap
fi

rm -rf "$source_alias"
mkdir -p "$source_alias" "$vector_prefix"
for file in "$repo"/*.MAC "$repo"/*.LNK; do
    [ -e "$file" ] || continue
    ln -s "$file" "$source_alias/$(basename "$file")"
done
: > "$source_alias/POKEY.DAT"
ln -sf "$repo/WSROOT.LNK" "$source_alias/WSMAIN.LNK"
rm -f "$vector_prefix/WSVROM.ol" "$vector_prefix/WSVROM.hex"

"$mac69" -2_pass -ignore -include="$source_alias" \
    -output="$vector_prefix/WSVROM" -list="$vector_prefix/WSVROM" \
    "$source_alias/WSVROM.MAC" >/dev/null
if ! "$llf" -nobinary -output="$vector_prefix/WSVROM.hex" \
    "$vector_prefix/WSVROM.ol" >/dev/null; then
    # LLF returns 1 for the documented VGCKS0 warning even though it emits a
    # complete image. The Python step supplies that historical checksum word.
    test -s "$vector_prefix/WSVROM.hex" || exit 1
fi

python3 "$repo/tools/generate_roms.py" --output "$output" \
    --vector-hex "$vector_prefix/WSVROM.hex"
python3 "$repo/tools/validate_roms.py" "$output"
python3 "$repo/tools/package_roms.py" "$output" "$output/../starwars1.zip"
printf '%s\n' "Reproducible ROM build complete: $output/../starwars1.zip"
