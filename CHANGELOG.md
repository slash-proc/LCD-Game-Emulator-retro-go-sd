# Changelog

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
