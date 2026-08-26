# Atari Star Wars archive

This repository is a historical Atari Star Wars arcade source archive. The
main program, AVG, mathbox, and sound sources are MAC69 assembly (`.MAC`);
`.LDA` files are VMS load-record images, and `.DOC` files document the boards,
ROMs, memory map, options, and tests.

## Compile the original source

The checked-in procedures require the original VMS tools `MAC69` and `LINKM`:

```text
@MACIT.COM
@SNDMAC.COM
@LINKIT.COM
```

From Termux or Linux, synchronize first with `tools/build-legacy.sh`. It
selects `star-wars.build` (or `star-wars.make`) beside this checkout and does
not build in the source tree. A compatible VMS environment is still required
to execute the commands above; no modern assembler replacement is assumed.

## Run in a browser

The supported browser route is a reduced MAME WebAssembly build. Install
Emscripten, obtain a MAME checkout outside this repository, and run:

```sh
MAME_SOURCE=/path/to/mame tools/build-mame-wasm.sh
python3 tools/validate_roms.py /path/to/raw-roms
python3 tools/package_roms.py /path/to/raw-roms star-wars.build/mame-wasm/starwars.zip
```

The raw ROM directory must contain the exact members and hashes in
`tools/rom-manifest.txt`. Existing `.LDA` files are not raw MAME members and
are intentionally rejected until a proven record conversion is available.
Copy the generated `starwars-web.js`, `starwars-web.wasm`, and ROM package
into `web/`/`web/roms/`, then serve it over HTTP:

```sh
python3 -m http.server 8000 --directory web
```

Open `http://127.0.0.1:8000/`. The included `web/mame-loader.js` starts the
`starwars` driver and maps the MAME display canvas.
