# Required original inputs

| Input | Required identity |
| --- | --- |
| USA ROM | 4,194,304 bytes; title `KLONOA2`; code `AN6E`; maker `AF`; ver `0`; checksum `0xCA` |
| ROM CRC32 | `0x8BD23A7F` |
| ROM SHA-1 | `35c05676e65fd4c92220861662cd3709342f36e2` |
| ROM SHA-256 | `2309b8c97aeb7fb64fcde35576c64de3a7a37c56d8ff5a6eee5844743753ab15` |
| Retail GBA BIOS | 16,384 bytes |
| BIOS CRC32 | `0x81977335` |
| BIOS SHA-1 | `300c20df6731a33952ded8c436f7f186d25d3492` |

Detected cartridge save signature: `EEPROM_V124` at file offset `0x1D5618`.
EEPROM capacity (4 Kbit / 512 B vs 64 Kbit / 8 KiB) is left for runtime
detection until verified by cold save/load testing.

Both inputs must be supplied locally by the user. Neither ROM nor BIOS is
committed or downloaded by this repository.
