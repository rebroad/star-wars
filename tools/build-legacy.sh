#!/bin/sh
set -eu

source_repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -d "$source_repo.build" ]; then
    build_tree=$source_repo.build
elif [ -d "$source_repo.make" ]; then
    build_tree=$source_repo.make
else
    build_tree=$source_repo.build
    mkdir -p "$build_tree"
fi

command -v cpto >/dev/null 2>&1 || {
    echo "error: cpto is required to synchronize the source tree" >&2
    exit 2
}

cpto "$source_repo" "$build_tree"
printf '%s\n' "Synchronized source into $build_tree"
printf '%s\n' "The original build requires a VMS environment providing MAC69 and LINKM."
printf '%s\n' "On VMS, run: @MACIT.COM, @SNDMAC.COM, then @LINKIT.COM"
