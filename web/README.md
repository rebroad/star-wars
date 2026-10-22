# Browser player

This is a static shell for a reduced MAME WebAssembly build. It is not a
JavaScript 6809 reimplementation: MAME supplies the Atari hardware model,
vector display, sound, mathbox, and controls.

## Prepare the assets

1. Obtain a MAME source checkout outside this repository and install
   Emscripten.
2. Run `MAME_SOURCE=/path/to/mame tools/build-browser.sh`; it creates the
   ROM package, builds the JavaScript/WebAssembly bundle, and installs both
   browser assets. Set `WEBASSEMBLY=0` only when ASM.js is specifically needed.

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
