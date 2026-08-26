#!/usr/bin/env python3
"""Validate and package a MAME Star Wars ROM directory."""

from pathlib import Path
import hashlib
import sys
import zipfile


def entries():
    for line in Path(__file__).with_name("rom-manifest.txt").read_text().splitlines():
        if line and not line.startswith("#"):
            name, size, sha1 = line.split()
            yield name, int(size), sha1


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print("usage: package_roms.py ROM_DIRECTORY [OUTPUT_ZIP]", file=sys.stderr)
        return 2
    rom_dir = Path(sys.argv[1])
    output = Path(sys.argv[2]) if len(sys.argv) == 3 else Path("starwars.zip")
    missing = []
    for name, expected_size, expected_sha1 in entries():
        path = rom_dir / name
        if not path.is_file():
            missing.append(name)
            continue
        actual_sha1 = hashlib.sha1(path.read_bytes()).hexdigest()
        if path.stat().st_size != expected_size or actual_sha1 != expected_sha1:
            print(f"MISMATCH {name}: size={path.stat().st_size} sha1={actual_sha1}", file=sys.stderr)
            return 1
    if missing:
        print("Cannot package: missing ROM members:", file=sys.stderr)
        for name in missing:
            print(f"  {name}", file=sys.stderr)
        return 1
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_STORED) as archive:
        for name, _, _ in entries():
            archive.write(rom_dir / name, arcname=name)
    print(f"Wrote validated ROM package: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
