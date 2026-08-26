# Repository Guidelines

## Project Structure & Module Organization

This repository contains the original Atari Star Wars hardware and software
archive. `.MAC` files are 6809 assembly sources; `WS*.MAC` and related files
make up the main game/AVG code, while `SND*.MAC` and `SWVOC*.MAC` cover sound.
`TC*.MAC` contains test/utility code. `.DOC` files describe hardware,
memory maps, ROMs, options, and diagnostics. `.LDA`, `.MAP`, `.LNK`, and `.LIS`
files are ROM, linker, map, and listing artifacts. `.COM` files are VMS DCL
build and comparison procedures. Keep new documentation near the relevant
legacy file and do not rename historical artifacts casually.

## Build, Test, and Development Commands

The checked-in build scripts target the original VMS toolchain, including
`MAC69` and `LINKM`:

```text
@MACIT.COM       ! assemble the main program sources
@SNDMAC.COM      ! assemble sound sources
@LINKIT.COM      ! link overlays and root image
@ROMIT.COM       ! prepare a ROM build from object files
```

Run these only in a compatible VMS environment. For local experimentation,
edit this source tree but copy it to a sibling build tree (for example
`../star-wars.build`) before building; never place generated output in the
source checkout. There is no automated test runner. Use the procedures in
`TEST.DOC` and the hardware diagnostics (`*TST.MAC`) when the target hardware
or an appropriate emulator is available.

## Coding Style & Naming Conventions

Preserve the existing fixed-format assembly layout, uppercase labels and
mnemonics, and established filename prefixes. Keep comments useful for
hardware addresses, timing, and board behavior. Match surrounding whitespace
and line conventions rather than reformatting whole files. Normalize new text
files to LF; `.gitattributes` enables automatic text detection and LF
normalization.

## Testing Guidelines

For source changes, assemble the affected module and relink the appropriate
image, then inspect assembler/linker diagnostics and generated maps. Record
any required hardware or emulator validation in the change description.

## Commit & Pull Request Guidelines

Use short, imperative commit subjects (the existing history is minimal, so
include the affected subsystem, for example `Fix AVG vector setup`). Explain
why a change is needed, identify generated artifacts, and include test or
hardware-validation results. Pull requests should keep unrelated binary
churn out of the diff and call out any intentionally changed ROM images.

## Safety and Repository Hygiene

Do not commit secrets, temporary build directories, or unreviewed generated
files. Preserve historical bytes and line endings unless the change requires
otherwise. Before submitting, review `git diff` and `git status` to confirm
only the intended files are staged.
