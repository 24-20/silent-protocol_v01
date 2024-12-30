@echo off
setlocal EnableDelayedExpansion
echo Starting browsers with session restoration...
REM Read the browser states JSON file
if not exist "%~dp0results\browser_states.json" (
    echo Browser states file not found
    exit /b 1
)
REM Parse JSON using PowerShell
for /f "tokens=* usebackq" %%a in (powershell -Command "(Get-Content '%~dp0results\browser_states.json' | ConvertFrom-Json).PSObject.Properties | Where-Object { $_.Value.wasRunning -eq $true } | Select-Object -ExpandProperty Name") do (
    set "browser=%%a"

    if "!browser!"=="chrome" (
        echo Starting Chrome...
        start "" /B "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
            --restore-last-session ^
            --session-restore-standalone-timeout=60 ^
            --disable-session-crashed-bubble ^
            --disable-features=TabGroups ^
            --password-store=basic ^
            --no-first-run
    )

    if "!browser!"=="edge" (
        echo Starting Edge...
        start "" /B "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ^
            --restore-last-session ^
            --session-restore-standalone-timeout=60 ^
            --disable-session-crashed-bubble ^
            --disable-features=TabGroups ^
            --password-store=basic ^
            --no-first-run
    )
)
echo Browser restart process completed.
