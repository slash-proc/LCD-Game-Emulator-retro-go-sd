# LCD-Game-Emulator — Retro-Go SD core

Standalone dynamic core for
[LCD-Game-Emulator](https://github.com/bzhxx/LCD-Game-Emulator)
(Nintendo Game & Watch / Sharp SM5xx LCD handhelds) on
[Game & Watch Retro-Go SD](https://github.com/sylverb/game-and-watch-retro-go-sd).

| | |
|--|--|
| Packed binary | `LCD-Game-Emulator.bin` → `/cores/LCD-Game-Emulator.bin` |
| ROMs | `/roms/gw/*.gw` |
| Host preview | `./LCD-Game-Emulator_host [rom.gw]` |

## Memory layout

| Region | Contents |
|--------|----------|
| **ITCM** (~13 KiB used) | Hot CPU/gfx `.text` only (`sm5*`, `gw_graphic`, `gw_system`) |
| **RAM_EMU** | Entry + main/i18n/romloader, all `.data`/`.bss` (`GW_ROM` 400 KiB, JPEG scratch, CPU state) |
| **DTCM** | Prefer `dtc_*` for any new small hot state (not used for ITCM data) |
| **AHB** | Avoid — smaller free heap than older monolithic builds |

ITCM is **code-only** (no ROM buffers / CPU RAM in ITCM).

## Build

```bash
make                 # → LCD-Game-Emulator.bin (logos inverted from icons BMP)
make host            # → LCD-Game-Emulator_host (SDL2)
make host HOST_SDL=3
make docker          # ARM build in sylverb/retro-go-sd-builder
```

Packaging uses `--logo-invert` on `src/assets/pad.bmp` / `header.bmp`
(from firmware `icons/c_gw.bmp` + `h_gw.bmp`).

## Requirements

Same as the Retro-Go SD core template: `arm-none-eabi-gcc`, Python 3 + Pillow,
optional SDL2/3 for host. See `CLAUDE.md` for the ABI / memory map.

## License

- Port / SDK glue: same as Retro-Go SD
- Emulator sources under `src/cpus` + `src/gw_sys`: GPLv3 (see `src/LCD-Game-Emulator.LICENSE`)
