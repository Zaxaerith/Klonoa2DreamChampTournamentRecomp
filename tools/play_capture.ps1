param(
    [switch]$NoLauncher,
    [string]$Rom,
    [string]$Bios,
    [string]$Save
)

. "$PSScriptRoot\common.ps1"

$Exe = Join-Path $ProjectRoot 'build\Klonoa2DreamChampTournamentRecomp.exe'
if (-not (Test-Path -LiteralPath $Exe)) {
    throw "Host executable not found: $Exe. Build the Release target first."
}

$TmpRoot = Join-Path $ProjectRoot '.tmp'
$CaptureDir = Join-Path $TmpRoot 'manual_captures'
New-Item -ItemType Directory -Force -Path $TmpRoot, $CaptureDir | Out-Null

$env:TMP = $TmpRoot
$env:TEMP = $TmpRoot
$env:TMPDIR = $TmpRoot

$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$CovJson = Join-Path $CaptureDir "run_$Stamp.json"
$MissFrag = Join-Path $CaptureDir "misses_$Stamp.toml.frag"
$env:GBARECOMP_COVERAGE_JSON = $CovJson
$env:GBARECOMP_MISS_FRAG = $MissFrag

$ArgList = @()
if ($NoLauncher) {
    if (-not $Rom) { $Rom = $DefaultRom }
    if (-not $Bios) { $Bios = $DefaultBios }
    if (-not $Save) { $Save = Join-Path $ProjectRoot 'saves\klonoa2_dct_usa.sav' }
    Assert-Rom $Rom
    Assert-Bios $Bios
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Save) | Out-Null
    $ArgList = @(
        '--rom', $Rom,
        '--bios', $Bios,
        '--config', (Join-Path $ProjectRoot 'game.toml'),
        '--save', $Save,
        '--window'
    )
}

Write-Host "==> Starting manual capture session ($Stamp)"
Write-Host "    Coverage JSON: $CovJson"
Write-Host "    Miss proposal: $MissFrag"

$StartParams = @{
    FilePath         = $Exe
    WorkingDirectory = $ProjectRoot
    Wait             = $true
    PassThru         = $true
}
if ($ArgList.Count -gt 0) {
    $StartParams.ArgumentList = $ArgList
}

$Proc = Start-Process @StartParams
Write-Host "==> Host exited with code $($Proc.ExitCode)"

if (-not (Test-Path -LiteralPath $CovJson)) {
    Write-Warning "Coverage JSON was not written (session exited before runtime start or aborted): $CovJson"
    exit $Proc.ExitCode
}

$Cov = Get-Content -LiteralPath $CovJson -Raw | ConvertFrom-Json
Write-Host "=== Manual Capture Summary ==="
Write-Host "self_heal_coverage         : $($Cov.coverage)"
Write-Host "distinct_misses            : $($Cov.distinct_misses)"
Write-Host "interpreted_insns          : $($Cov.interpreted_insns)"
Write-Host "jump_table_candidate_regions: $($Cov.jump_table_candidate_regions)"

if ($Cov.misses -and $Cov.misses.Count -gt 0) {
    Write-Host "Missed PCs:"
    foreach ($m in $Cov.misses) {
        Write-Host ("  {0} ({1}) bridged={2} jt_candidate={3}" -f $m.pc, $m.mode, $m.bridged, $m.jump_table_candidate)
    }
}
