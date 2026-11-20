@echo off
setlocal
set PART1=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa
set PART2=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab
set OUT=Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso

if not exist "%PART1%" (
    echo [ERROR] Missing %PART1%
    pause
    exit /b 1
)
if not exist "%PART2%" (
    echo [ERROR] Missing %PART2%
    pause
    exit /b 1
)

echo Merging ISO parts into %OUT% ...
copy /b "%PART1%" + "%PART2%" "%OUT%"
if errorlevel 1 (
    echo [ERROR] Merge failed!
    pause
    exit /b 1
)

echo.
echo Verifying SHA-256 (compare with SHA256SUMS.txt):
certutil -hashfile "%OUT%" SHA256
echo.
echo Done!
pause
