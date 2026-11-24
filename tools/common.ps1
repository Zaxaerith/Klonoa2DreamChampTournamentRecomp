$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DefaultRom = Join-Path $ProjectRoot 'Klonoa 2 - Dream Champ Tournament (USA).gba'
$DefaultBios = $null
$Toolchain = $null
$SdlRoot = $null
$CMake = 'cmake'
$Ninja = 'ninja'
if (Test-Path -LiteralPath "$ProjectRoot\.local.ps1") { . "$ProjectRoot\.local.ps1" }

function Assert-Rom([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path).Path)
    if ($bytes.Length -ne 4194304 -or
        [Text.Encoding]::ASCII.GetString($bytes, 0xA0, 12).TrimEnd([char]0) -ne 'KLONOA2' -or
        [Text.Encoding]::ASCII.GetString($bytes, 0xAC, 6) -ne 'AN6EAF' -or
        (Get-FileHash -LiteralPath $Path -Algorithm SHA1).Hash.ToLowerInvariant() -ne '35c05676e65fd4c92220861662cd3709342f36e2') {
        throw 'Expected USA KLONOA2 AN6E/AF, 4 MiB, SHA1 35c05676e65fd4c92220861662cd3709342f36e2.'
    }
}

function Assert-Bios([string]$Path) {
    if (-not $Path) { throw 'Supply -Bios or DefaultBios in private .local.ps1.' }
    if ((Get-Item -LiteralPath $Path).Length -ne 16384 -or
        (Get-FileHash -LiteralPath $Path -Algorithm SHA1).Hash.ToLowerInvariant() -ne '300c20df6731a33952ded8c436f7f186d25d3492') {
        throw 'Expected retail 16 KiB GBA BIOS, SHA1 300c20df6731a33952ded8c436f7f186d25d3492.'
    }
}

function Invoke-Logged([string]$Program, [string[]]$Arguments, [string]$Log) {
    $ErrorActionPreference = 'Continue'
    & $Program @Arguments *> $Log
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { Get-Content -LiteralPath $Log -Tail 35; throw "$Program exited $code; see $Log" }
}
