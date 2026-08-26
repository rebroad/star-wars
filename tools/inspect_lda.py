#!/usr/bin/env python3
"""Inspect the legacy MAC69/VMS load-record format without rewriting it."""

from pathlib import Path
import sys


def inspect(path: Path) -> int:
    data = path.read_bytes()
    offset = 0
    records = []
    while offset + 6 <= len(data):
        kind = int.from_bytes(data[offset : offset + 2], "little")
        length = int.from_bytes(data[offset + 2 : offset + 4], "little")
        address = int.from_bytes(data[offset + 4 : offset + 6], "little")
        if kind == 0 and length == 0:
            break
        total = length + 1
        if kind != 1 or length < 5 or offset + total > len(data):
            print(f"{path}: invalid record at byte {offset}", file=sys.stderr)
            return 1
        records.append((address, length - 5))
        offset += total

    if not records:
        print(f"{path}: no load records found", file=sys.stderr)
        return 1
    low = min(address for address, _ in records)
    high = max(address + size for address, size in records)
    padding = len(data) - offset
    print(
        f"{path}: records={len(records)} load_range=${low:04X}-${high:04X} "
        f"payload_bytes={sum(size for _, size in records)} trailing_bytes={padding}"
    )
    return 0


def main() -> int:
    paths = [Path(arg) for arg in sys.argv[1:]] or sorted(Path(".").glob("*.LDA"))
    if not paths:
        print("No .LDA files supplied or found", file=sys.stderr)
        return 2
    return max(inspect(path) for path in paths)


if __name__ == "__main__":
    raise SystemExit(main())
