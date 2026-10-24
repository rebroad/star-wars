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

From Termux or Linux, the original VMS procedures still require a compatible
VMS environment. The supported modern conversion route is reproducible from
the checked-in load records:

```sh
tools/build-roms.sh
```

The script bootstraps MAC69 and LLF under `$PREFIX/tmp` when needed, assembles
the vector ROM, converts every `.LDA`, validates all 13 MAME members, and
writes `roms-built/starwars1.zip`.

## Run in a browser

The supported browser route is a reduced MAME WebAssembly build.
Install Emscripten, obtain a MAME checkout outside this repository, and run:

```sh
MAME_SOURCE=/path/to/mame tools/build-browser.sh
```

The script invokes the MAME fork's maintained `build_web.sh`, which writes
`starwarswasm.js`, `starwarswasm.wasm`, `roms.js`, `roms.data`, and its
generated `index.html` to `web/`. The ROM archive is embedded through
Emscripten's standard preload data; no custom ZIP loader is used. The default
is single-threaded WebAssembly; workers are not enabled.
Serve the result over HTTP:

```sh
python3 -m http.server 8000 --directory web
```

Open `http://127.0.0.1:8000/`.

GitHub Actions also builds the WebAssembly emulator on pushes to `main` and via the
manual `Build browser emulator` workflow. Its artifact intentionally excludes
ROM contents; use `tools/build-browser.sh` locally to assemble the complete
player from the repository archive.
