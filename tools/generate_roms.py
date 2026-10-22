#!/usr/bin/env python3
"""Generate the MAME starwars1 ROM members from this source archive."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def lda(path: Path) -> dict[int, int]:
    """Read the archive's little-endian VMS load records."""
    raw = path.read_bytes()
    result: dict[int, int] = {}
    pos = 0
    while pos + 7 <= len(raw):
        kind, length, address = struct.unpack_from("<HHH", raw, pos)
        if kind == 0 or length == 0:
            break
        total = length + 1  # record length excludes its checksum byte
        data = raw[pos + 6 : pos + total - 1]
        for offset, value in enumerate(data):
            result[address + offset] = value
        pos += total
    return result


def range_bytes(records: dict[int, int], start: int, size: int) -> bytes:
    return bytes(records.get(start + i, 0) for i in range(size))


def write(output: Path, name: str, data: bytes) -> None:
    (output / name).write_bytes(data)


def parse_tekhex(path: Path) -> dict[int, int]:
    """Read LLF's Extended TekHex data records (type 6)."""
    result: dict[int, int] = {}
    for line in path.read_text(errors="replace").splitlines():
        for match in re.finditer(r"%([0-9A-Fa-f]+)", line):
            record = match.group(1)
            if len(record) < 4 or record[2] != "6":
                continue
            payload = record[5:]  # count, type, and checksum precede it
            length_nibble = int(payload[0], 16) or 16
            address_digits = length_nibble
            if len(payload) < address_digits + 1:
                continue
            address = int(payload[1 : address_digits + 1], 16)
            data_hex = payload[address_digits + 1 :]
            for offset, value in enumerate(bytes.fromhex(data_hex)):
                result[address + offset] = value
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--vector-hex", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    output = args.output
    output.mkdir(parents=True, exist_ok=True)

    root = lda(ROOT / "JUN22R.LDA")
    overlay = lda(ROOT / "JUN22O.LDA")
    sound = lda(ROOT / "SNDAUX.LDA")
    avgrom = lda(ROOT / "AVGROM.LDA")
    microcode = lda(ROOT / "SWMP.LDA")

    # The June 22 root image has the five program ROMs at these CPU ranges.
    write(output, "136021.102.1hj", range_bytes(root, 0x8000, 0x2000))
    write(output, "136021.203.1jk", range_bytes(root, 0xA000, 0x2000))
    write(output, "136021.104.1kl", range_bytes(root, 0xC000, 0x2000))
    write(output, "136021.206.1m", range_bytes(root, 0xE000, 0x2000))
    write(output, "136021.114.1f", bytes(
        list(range_bytes(root, 0x6000, 0x2000))
        + list(range_bytes(overlay, 0x6000, 0x2000))
    ))
    write(output, "136021-107.1jk", range_bytes(sound, 0x4000, 0x2000))
    write(output, "136021-208.1h", range_bytes(sound, 0x6000, 0x2000))
    write(output, "136021-109.4b", range_bytes(avgrom, 0, 0x100))

    # SWMP contains two sparse 1 KiB banks. Each byte supplies one nibble to
    # the corresponding PROM; the zero-filled holes are intentional.
    bank0 = range_bytes(microcode, 0, 0x400)
    bank1 = range_bytes(microcode, 0x400, 0x400)
    write(output, "136021-110.7h", bytes(value >> 4 for value in bank1))
    write(output, "136021-111.7j", bytes(value & 0x0F for value in bank1))
    write(output, "136021-112.7k", bytes(value >> 4 for value in bank0))
    write(output, "136021-113.7l", bytes(value & 0x0F for value in bank0))

    vector_records = parse_tekhex(args.vector_hex)
    vector = bytearray(range_bytes(vector_records, 0x3000, 0x1000))
    # VGCKS0 is a linker symbol absent from this archive's standalone source.
    # SW3.DOC identifies the checksum word; the historical ROM hash fixes its
    # little-endian value as EC1E.
    vector[0:2] = struct.pack("<H", 0xEC1E)
    write(output, "136021-105.1l", bytes(vector))
    print(f"Generated ROM members in {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
