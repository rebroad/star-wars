# Browser player

The browser assets are generated from the MAME fork's maintained
`build_web.sh`. MAME supplies the Atari hardware model, vector display, sound,
mathbox, and controls; this is not a JavaScript 6809 reimplementation.

## Prepare the assets

1. Obtain the MAME fork checkout and install Emscripten 3.1.35.
2. Run `MAME_SOURCE=/path/to/mame tools/build-browser.sh`; it creates the
   ROM archive, invokes MAME's `build_web.sh`, and copies its generated page,
   WebAssembly bundle, and `roms.data` preload into this directory.

The checked-in `.LDA` files are VMS load records, not MAME ROM members. Use
`python3 tools/inspect_lda.py` to inspect them; do not rename or zip them as
ROMs without proving the record conversion and revision hashes.

## Run locally

Serve the generated directory over HTTP; browsers generally block WebAssembly
and preload files from `file://` URLs:

```sh
python3 -m http.server 8000 --directory web
```

Open `http://127.0.0.1:8000/`. For deployment, publish the same static files
through GitHub Pages or another HTTPS static host, subject to ROM licensing
and distribution rights.
