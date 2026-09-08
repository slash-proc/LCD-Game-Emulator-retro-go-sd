# Changelog

## [v0.0.2] - 2026-09-08

### Added

- Published under the [GWRG distribution
  spec](https://github.com/slash-proc/gwrg-dist-spec): a `manifest.json`
  describing this core and the system it provides, an offline bundle, and a
  GitHub Pages mirror of `dist/` that a web installer can read without a human
  in the loop.
- `symbols[]` publishes the linked ELF so a crash address from a device can be
  resolved back to a function. It is named by the manifest and mirrored, but is
  not part of the install set and never reaches the card.
- `gwrg.json`, the hand-written half of the manifest: the short console name
  and whether compressed ROMs work. Everything else -- the system, its folder,
  extensions and browse mode, the firmware ABI, sizes and hashes -- is derived
  from the packed binary at release time, so the manifest and the firmware
  cannot disagree about which folder the system reads.
- The Game & Watch tab is keyed by the `gw` folder the packed core names. A
  `.gw` file is a complete simulation -- SM5xx ROM and artwork in one package --
  so there is nothing else for a user to install and no `bios[]` to declare.

### Changed

- `scripts/make_manifest.py`, `build_dist.py`, `make_bundle.py` and
  `stage_release.py` are now the shared copies, byte-identical across every
  project. A script that has to be edited on the way in is a script that
  drifts.
- The Makefile answers `print-SIDECARS` and `print-RO_BIN`. This core installs
  neither, but the shared release script reads its variables positionally: a
  missing target shifts every later value onto the wrong name.


## [v0.0.1]

Initial standalone Retro-Go SD core release of LCD-Game-Emulator (Nintendo Game & Watch / Sharp SM5xx LCD handhelds).

### Added

- Hot CPU/gfx code linked into ITCM (~13 KiB); large buffers (`GW_ROM`, JPEG
  scratch, CPU state) stay in RAM_EMU — no ITCM data, AHB avoided for bulk allocations.

### Changed

- Nothing.

### Fixed

- Nothing.

### Install

**Core**

- Copy `LCD-Game-Emulator.bin` to `/cores/` on the SD card.
- Place ROMs under `/roms/gw/` (extension `.gw`).
- Requires firmware whose ABI matches `SDK_VERSION` in this repository.
