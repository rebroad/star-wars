#!/usr/bin/env python3
"""Validate a user-provided MAME Star Wars ROM directory."""

from pathlib import Path
import hashlib
import sys


def main() -> int:
    rom_dir = Path(sys.argv[1]) if len(sys.argv) == 2 else Path("roms")
    manifest = Path(__file__).with_name("rom-manifest.txt")
    failures = 0
    for line in manifest.read_text().splitlines():
        if not line or line.startswith("#"):
            continue
        name, expected_size, expected_sha1 = line.split()
        path = rom_dir / name
        if not path.is_file():
            print(f"MISSING {name}")
            failures += 1
            continue
        size = path.stat().st_size
        digest = hashlib.sha1(path.read_bytes()).hexdigest()
        if size != int(expected_size) or digest != expected_sha1:
            print(f"MISMATCH {name} size={size} sha1={digest}")
            failures += 1
        else:
            print(f"OK      {name}")
    if failures:
        print(f"Validation failed: {failures} ROM member(s)", file=sys.stderr)
        return 1
    print("Validated Atari Star Wars set 1 ROM directory")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
