# Browser player

This is a static shell for a reduced MAME WebAssembly build. It is not a
JavaScript 6809 reimplementation: MAME supplies the Atari hardware model,
vector display, sound, mathbox, and controls.

## Prepare the assets

1. Obtain a MAME source checkout outside this repository and install
   Emscripten.
2. Run `MAME_SOURCE=/path/to/mame tools/build-mame-wasm.sh`. The output is
   placed in the sibling build tree selected by the repository rules.
3. Supply the legally obtained ROM members listed in
   `tools/rom-manifest.txt`, then run `python3 tools/validate_roms.py roms`.
4. Package the validated files as `starwars.zip` under `web/roms/`, and copy
   the generated `starwars-web.js` and `starwars-web.wasm` beside
   `index.html`. The included `mame-loader.js` supplies the ROM path and
   starts the `starwars` driver.

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
