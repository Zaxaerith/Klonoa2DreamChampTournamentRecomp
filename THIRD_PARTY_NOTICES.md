# Third-party notices

| Component | Pin | Terms |
| --- | --- | --- |
| GBARecomp | `c1a5fda36fb41c2fcba6c901692006ac69d50555` (`v0.4.1`) | PolyForm Noncommercial 1.0.0, Copyright 2026 Matthew Stanley; file exceptions in `gbarecomp/THIRD_PARTY_ATTRIBUTION.md` |
| recomp-ui | `70f4e015b434a1b46a657474e207c17c925f5a37` | MIT, Copyright 2026 Matthew Stanley |
| Dear ImGui | Vendored in `recomp-ui` | MIT |
| SDL2 | Host dependency | zlib |
| toml++ | CMake FetchContent / `GBARECOMP_TOMLPP_INCLUDE_DIR` | MIT |

Framework BIOS HLE files (`gbarecomp/src/runtime/bios_hle.cpp` and `bios_hle.h`)
derive from mGBA under MPL-2.0. Retail GBA BIOS LLE remains the default.
No ROMs, BIOS dumps, saves, or generated cartridge/BIOS code are distributed
in this repository.
