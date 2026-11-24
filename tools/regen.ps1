param([string]$Rom, [string]$Bios, [string]$Generator, [int]$MaxFunctions = 65536)
. "$PSScriptRoot\common.ps1"
if (-not $Rom) { $Rom = $DefaultRom }
if (-not $Bios) { $Bios = $DefaultBios }
if (-not $Generator) {
    $candidates = @(
        "$ProjectRoot\.tmp\cli\_internal\gba_recompile-core.exe",
        "$ProjectRoot\build\host\framework\gba_recompile.exe"
    )
    $Generator = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $Generator -or -not (Test-Path -LiteralPath $Generator)) {
    throw 'gba_recompile executable not found. Pass -Generator or place v0.4.1 CLI under .tmp/cli.'
}
Assert-Rom $Rom
Assert-Bios $Bios
New-Item -ItemType Directory -Force -Path "$ProjectRoot\logs","$ProjectRoot\src\gen\cart","$ProjectRoot\src\gen\bios" | Out-Null
Invoke-Logged $Generator @('--rom',$Rom,'--config',"$ProjectRoot\game.toml",'--out',"$ProjectRoot\src\gen\cart",'--max-functions',"$MaxFunctions") "$ProjectRoot\logs\regen-cart.log"
Invoke-Logged $Generator @('--bios',$Bios,'--config',"$ProjectRoot\gbarecomp\bios\gba_bios.toml",'--out',"$ProjectRoot\src\gen\bios") "$ProjectRoot\logs\regen-bios.log"
$support = "$ProjectRoot\src\codegen_tail_macros.h"
Copy-Item -LiteralPath $support -Destination "$ProjectRoot\src\gen\bios\codegen_tail_macros.h" -Force
Get-Content -LiteralPath "$ProjectRoot\logs\regen-cart.log" -Tail 12
Get-Content -LiteralPath "$ProjectRoot\logs\regen-bios.log" -Tail 8
