@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "PART1=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa"
set "PART2=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab"
set "OUT=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso"
set "EXPECTED_SHA256=07aa728e5b810b9ddb7cc5006083957323709a29a34061befac200a51fd6f835"

if not exist "%PART1%" (
    echo [ERROR] Missing %PART1%
    echo Please place this script in the same folder as the downloaded .partaa and .partab files.
    pause
    exit /b 1
)
if not exist "%PART2%" (
    echo [ERROR] Missing %PART2%
    echo Please place this script in the same folder as the downloaded .partaa and .partab files.
    pause
    exit /b 1
)

echo [1/2] Merging ISO parts into %OUT% ...
copy /b "%PART1%" + "%PART2%" "%OUT%"
if errorlevel 1 (
    echo [ERROR] Merge failed!
    pause
    exit /b 1
)

echo.
echo [2/2] Verifying SHA-256 checksum...
set "ACTUAL_SHA256="
for /f "skip=1 tokens=1" %%H in ('certutil -hashfile "%OUT%" SHA256') do (
    if not defined ACTUAL_SHA256 set "ACTUAL_SHA256=%%H"
)

echo Expected: %EXPECTED_SHA256%
echo Actual  : !ACTUAL_SHA256!

if /i "!ACTUAL_SHA256!"=="%EXPECTED_SHA256%" (
    echo.
    echo [OK] SHA-256 verified! %OUT% is ready to use.
) else (
    echo.
    echo [FAIL] SHA-256 mismatch! Please re-download the split files and try again.
    pause
    exit /b 1
)

echo.
pause
