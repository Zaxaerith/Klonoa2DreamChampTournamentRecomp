# Klonoa2DreamChampTournamentRecomp

Static GBA recompilation host skeleton for **Klonoa 2: Dream Champ Tournament (USA, AN6E)** using [GBARecomp](https://github.com/mstan/gbarecomp) (`v0.4.1`) and [recomp-ui](https://github.com/mstan/recomp-ui).

Supply your own legally obtained USA cartridge ROM and retail GBA BIOS. No ROMs, BIOS dumps, saves, or generated C++ files are included in this repository.

## Required private inputs

| Input | Identity | Bytes | SHA-1 |
| --- | --- | ---: | --- |
| ROM | `Klonoa 2 - Dream Champ Tournament (USA).gba` (`KLONOA2`, `AN6E`/`AF`) | 4,194,304 | `35c05676e65fd4c92220861662cd3709342f36e2` |
| BIOS | Retail GBA BIOS | 16,384 | `300c20df6731a33952ded8c436f7f186d25d3492` |

- ROM CRC32: `0x8BD23A7F`
- ROM SHA-256: `2309b8c97aeb7fb64fcde35576c64de3a7a37c56d8ff5a6eee5844743753ab15`
- Save signature: `EEPROM_V124` at `0x1D5618` (native save path: `saves/klonoa2_dct_usa.sav`)

## Repository layout

- `gbarecomp/` — Pinned GBARecomp submodule (`v0.4.1`, `c1a5fda36fb41c2fcba6c901692006ac69d50555`)
- `recomp-ui/` — Pinned recomp-ui launcher submodule (`70f4e015b434a1b46a657474e207c17c925f5a37`)
- `game.toml` — ROM/BIOS identity & recompiler/runtime config
- `recomp/player.toml` — Path-free runtime defaults (`240x160` native view)
- `src/main.cpp`, `src/game_launcher_boot.cpp` — Thin Win32/SDL2 host & launcher seam
- `src/gen/` — Git-ignored codegen output (`cart/` and `bios/`)
- `tools/` — PowerShell regeneration, build, launch, and release audit scripts

## Build & codegen (developer)

1. Clone with submodules (`git clone --recurse-submodules ...`).
2. Generate cartridge and BIOS C++ into `src/gen/` with `./tools/regen.ps1` (or `gbarecomp.exe` / `gba_recompile.exe`).
3. Configure and build with CMake + Ninja + MinGW-w64 + SDL2 (or `./tools/build-host.ps1`).
4. Launch with `Play.cmd` or `./tools/run-host.ps1`.
