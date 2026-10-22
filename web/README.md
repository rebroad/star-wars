# Browser player

This is a static shell for a reduced MAME ASM.js build. It is not a
JavaScript 6809 reimplementation: MAME supplies the Atari hardware model,
vector display, sound, mathbox, and controls.

## Prepare the assets

1. Obtain a MAME source checkout outside this repository and install
   Emscripten.
2. Run `tools/build-roms.sh`, then copy
   `roms-built/starwars1.zip` to `web/roms/starwars.zip`.
3. Run `MAME_SOURCE=/path/to/mame tools/build-mame-wasm.sh`; it writes the
   ASM.js bundle beside this page. Set `WEBASSEMBLY=1` only when WASM is
   preferred.

The checked-in `.LDA` files are VMS load records, not MAME ROM members. Use
`python3 tools/inspect_lda.py` to inspect them; do not rename or zip them as
ROMs without proving the record conversion and revision hashes.

## Run locally

Serve this directory over HTTP; browsers generally block WebAssembly and ROM
fetches from `file://` URLs:

```sh
python3 -m http.server 8000 --directory web
```

Open `http://127.0.0.1:8000/`. For deployment, publish the same static files
through GitHub Pages or another HTTPS static host, subject to ROM licensing
and distribution rights.
