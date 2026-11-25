# Klonoa2DreamChampTournamentRecomp

Static GBA recompilation of **Klonoa 2: Dream Champ Tournament (USA, AN6E)** using [GBARecomp](https://github.com/mstan/gbarecomp) (`v0.4.1`) and [recomp-ui](https://github.com/mstan/recomp-ui).

Supply your own legally obtained USA cartridge ROM and retail GBA BIOS via the unified `recomp-ui` launcher or CLI. No ROMs, BIOS dumps, saves, or generated C++ files are included in this repository.

## Verified Status

- **Static Codegen**: `11,392` cartridge functions (`39` ARM / `11,353` Thumb across `16` shards) + `735` retail BIOS functions, including ROM-verified state-handler jump table `0x08154040` (`count = 52`) alongside `64` auto-detected jump tables.
- **Vision 1-1 Cold-Boot Verification**: `6,500`-frame deterministic run (BIOS boot → Namco → KLONOA WORKS → Title → Save creation → World Map → World 1 → Vision 1-1 movement, Wind Bullet, jump/double-jump, and Pause) verified **`FULLY_STATIC`** (`0` dispatch misses, `0` interpreted instructions, `0` `runtime_unimplemented_op`, `0` unhandled I/O).
- **Save Persistence**: `EEPROM_V124` auto-resolved to **4 Kbit (`512` bytes, 9-bit request)**; cold-boot reload confirmed `CONTINUE -> VISION 1-1 / x03`.
- **Windows GUI Host**: Native `240×160` presentation, `WIN32_EXECUTABLE TRUE` (`IMAGE_SUBSYSTEM_WINDOWS_GUI`, no console popup on double-click), and `recomp-ui` launcher ROM/BIOS selection with strict SHA-1 validation.

## Required Private Inputs

| Input | Identity | Bytes | SHA-1 |
| --- | --- | ---: | --- |
| ROM | `Klonoa 2 - Dream Champ Tournament (USA).gba` (`KLONOA2`, `AN6E`/`AF`) | 4,194,304 | `35c05676e65fd4c92220861662cd3709342f36e2` |
| BIOS | Retail GBA BIOS | 16,384 | `300c20df6731a33952ded8c436f7f186d25d3492` |

- ROM CRC32: `0x8BD23A7F`
- ROM SHA-256: `2309b8c97aeb7fb64fcde35576c64de3a7a37c56d8ff5a6eee5844743753ab15`
- Save signature: `EEPROM_V124` at `0x1D5618` (4 Kbit / `512` B; native save path: `saves/klonoa2_dct_usa.sav`)

## Repository Layout

- `gbarecomp/` — Pinned GBARecomp submodule (`v0.4.1`, `c1a5fda36fb41c2fcba6c901692006ac69d50555`)
- `recomp-ui/` — Pinned recomp-ui launcher submodule (`70f4e015b434a1b46a657474e207c17c925f5a37`)
- `game.toml` — ROM/BIOS identity, recompiler jump tables & runtime config
- `recomp/player.toml` — Path-free runtime defaults (`240×160` native view)
- `src/main.cpp`, `src/game_launcher_boot.cpp` — Thin Win32/SDL2 host & launcher seam
- `src/gen/` — Git-ignored codegen output (`cart/` and `bios/`)
- `tools/` — PowerShell regeneration, build, launch, manual coverage capture, and release audit scripts

## Build & Codegen (Developer)

1. Clone with submodules (`git clone --recurse-submodules ...`).
2. Generate cartridge and BIOS C++ into `src/gen/` with `./tools/regen.ps1` (or `gbarecomp.exe` / `gba_recompile.exe`).
3. Configure and build with CMake + Ninja + MinGW-w64 + SDL2 (or `./tools/build-host.ps1`).
4. Launch with `Play.cmd` or `./tools/run-host.ps1` (or select ROM/BIOS directly in the `recomp-ui` launcher).

## Contributing Coverage Captures (Worlds 1–5 / Hoverboard / Bosses)

Run a normal windowed play session with automatic coverage JSON export to `.tmp/manual_captures/`:

```powershell
.\tools\play_capture.ps1
# Or skip the launcher and launch directly:
.\tools\play_capture.ps1 -NoLauncher -Bios "path\to\gba_bios.bin"
```

After closing the game window, the script prints `self_heal_coverage`, `distinct_misses`, `interpreted_insns`, and `jump_table_candidate_regions` so verified ROM jump tables can be added to `game.toml`.
