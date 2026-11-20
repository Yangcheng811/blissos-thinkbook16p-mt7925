# Windows PowerShell script to merge split ISO parts and verify SHA-256
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$Part1 = "Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa"
$Part2 = "Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab"
$OutFile = "Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso"
$ExpectedSha256 = "07aa728e5b810b9ddb7cc5006083957323709a29a34061befac200a51fd6f835"

foreach ($p in @($Part1, $Part2)) {
    if (-not (Test-Path $p)) {
        Write-Error "Missing $p. Place this script in the same folder as the downloaded .partaa and .partab files."
        exit 1
    }
}

Write-Host "[1/2] Merging $Part1 + $Part2 -> $OutFile ..." -ForegroundColor Cyan
$outStream = [System.IO.File]::Create((Join-Path (Get-Location) $OutFile))
try {
    foreach ($p in @($Part1, $Part2)) {
        $inStream = [System.IO.File]::OpenRead((Join-Path (Get-Location) $p))
        try {
            $inStream.CopyTo($outStream)
        } finally {
            $inStream.Close()
        }
    }
} finally {
    $outStream.Close()
}

Write-Host "[2/2] Verifying SHA-256 checksum..." -ForegroundColor Cyan
$actual = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
Write-Host "Expected: $ExpectedSha256"
Write-Host "Actual  : $actual"

if ($actual -eq $ExpectedSha256) {
    Write-Host "`n[OK] SHA-256 verified! $OutFile is ready to use." -ForegroundColor Green
} else {
    Write-Host "`n[FAIL] SHA-256 mismatch! Please re-download the split files." -ForegroundColor Red
    exit 1
}
